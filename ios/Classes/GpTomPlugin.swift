import Flutter
import UIKit

public final class GpTomPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    private var eventSink: FlutterEventSink?
    private var isInitialized = false
    private var isDevelopment = false
    private var debugLogs = false
    private var redirectScheme: String = ""

    private let pendingStore = PendingStore()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = GpTomPlugin()

        let method = FlutterMethodChannel(
            name: Channels.methods, binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: method)

        let events = FlutterEventChannel(
            name: Channels.events, binaryMessenger: registrar.messenger())
        events.setStreamHandler(instance)

        registrar.addApplicationDelegate(instance)
    }

    public func onListen(
        withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink
    )
        -> FlutterError?
    {
        self.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "init" {
            handleInit(call, result)
            return
        }

        if let err = validatePluginState() {
            sendMethodResult(result, err)
            return
        }

        switch call.method {
        case "isInstalled":
            sendMethodResult(result, .success(isGpTomInstalled()))
        case "register":
            register(call, result)
        case "transaction":
            transaction(call, result)
        case "getState":
            getState(call, result)
        case "getDetail":
            getDetail(call, result)
        case "getPending":
            sendMethodResult(result, .success(pendingStore.read() ?? NSNull()))
        case "clearPending":
            pendingStore.clear()
            sendMethodResult(result, .success(NSNull()))
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleInit(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any] ?? [:]
        isDevelopment = args[JsonKeys.isDevelopment] as? Bool ?? false
        debugLogs = args[JsonKeys.debugLogs] as? Bool ?? false

        let scheme =
            (args[JsonKeys.iosRedirectScheme] as? String)?.trimmingCharacters(
                in: .whitespacesAndNewlines) ?? ""
        if scheme.isEmpty {
            sendMethodResult(
                result,
                .error(
                    code: ResultCodes.invalidArgument,
                    message: "\(JsonKeys.iosRedirectScheme) is required on iOS"
                )
            )
            return
        }

        redirectScheme = scheme

        GpTomLog.enabled = debugLogs
        GpTomLog.i("init()", ["args": args])

        isInitialized = true
        sendMethodResult(result, .success(NSNull()))
    }

    private func validatePluginState() -> PluginResponse? {
        if !isInitialized {
            return .error(
                code: ResultCodes.notInitialized, message: "Call GpTomManager.init() first")
        }

        if redirectScheme.isEmpty {
            return .error(
                code: ResultCodes.invalidArgument,
                message: "\(JsonKeys.iosRedirectScheme) is required on iOS")
        }

        if !isGpTomInstalled() {
            return .error(
                code: ResultCodes.notInstalled,
                message:
                    "GP tom app is not installed (or iOS blocked canOpenURL). Ensure Info.plist has LSApplicationQueriesSchemes: ['gptom']."
            )
        }

        return nil
    }

    private func isGpTomInstalled() -> Bool {
        guard let url = URL(string: "gptom://") else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }

    private func register(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any] ?? [:]
        let originRef = args[JsonKeys.originReferenceNum] as? String
        let clientId = args[JsonKeys.clientId] as? String
        let persist = args[JsonKeys.persistPending] as? Bool ?? true

        GpTomLog.i(
            "register()", ["originRef": originRef, "clientId": clientId, "persist": persist])

        let txId = UUID().uuidString

        if persist {
            pendingStore.save(
                transactionId: txId, originReferenceNum: originRef,
                createdAtMs: Int64(Date().timeIntervalSince1970 * 1000))
        }

        let registerResult = RegisterMapper.toMap(
            transactionId: txId,
            originReferenceNum: originRef,
            clientId: clientId
        )

        sendMethodResult(result, .success(registerResult))
    }

    private func transaction(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any] ?? [:]

        guard let txId = args[JsonKeys.transactionId] as? String, !txId.isEmpty else {
            sendMethodResult(
                result,
                .error(
                    code: ResultCodes.invalidArgument,
                    message: "\(JsonKeys.transactionId) is required"))
            return
        }
        guard let typeNum = args[JsonKeys.transactionType] as? NSNumber else {
            sendMethodResult(
                result,
                .error(
                    code: ResultCodes.invalidArgument,
                    message: "\(JsonKeys.transactionType) is required"))
            return
        }

        let typeCode = typeNum.intValue
        guard let kind = Kinds.fromTransactionType(typeCode) else {
            sendMethodResult(
                result,
                .error(
                    code: ResultCodes.invalidArgument,
                    message: "Unsupported \(JsonKeys.transactionType) value: \(typeCode)"
                )
            )
            return
        }

        let amount = (args[JsonKeys.amount] as? NSNumber)?.intValue
        if kind == Kinds.sale || kind == Kinds.refund {
            if amount == nil || amount! < 0 {
                sendMethodResult(
                    result,
                    .error(
                        code: ResultCodes.invalidArgument,
                        message: "\(JsonKeys.amount) is required for sale/refund")
                )
                return
            }
        }

        var cancelMode: Int? = nil
        var originTx: String? = nil
        if kind == Kinds.cancel {
            cancelMode = (args[JsonKeys.cancelMode] as? NSNumber)?.intValue
            if cancelMode == nil || (cancelMode != 1 && cancelMode != 2) {
                sendMethodResult(
                    result,
                    .error(
                        code: ResultCodes.invalidArgument,
                        message: "\(JsonKeys.cancelMode) must be 1 or 2 for cancel"))
                return
            }
            if cancelMode == 2 {
                originTx = args[JsonKeys.originTransactionId] as? String
                if originTx == nil || originTx!.isEmpty {
                    sendMethodResult(
                        result,
                        .error(
                            code: ResultCodes.invalidArgument,
                            message:
                                "\(JsonKeys.originTransactionId) is required for olderTransaction cancel"
                        ))
                    return
                }
            }
        }

        sendMethodResult(result, .success(NSNull()))

        let path = deeplinkPathForKind(kind).path

        let clientId = args[JsonKeys.clientId] as? String
        let printByPaymentApp = (args[JsonKeys.printByPaymentApp] as? Bool) ?? true
        let tipCollect = args[JsonKeys.tipCollect] as? Bool
        let tipAmount = (args[JsonKeys.tipAmount] as? NSNumber)?.intValue
        let originReferenceNum = args[JsonKeys.originReferenceNum] as? String

        var params: [String: String?] = [
            DeeplinkParamKeys.requestID: txId,
            DeeplinkParamKeys.redirectUrl: buildRedirectUrl(
                schemeUrl: redirectScheme, path: path),
            DeeplinkParamKeys.clientID: clientId,
            DeeplinkParamKeys.printByPaymentApp: boolStr(printByPaymentApp),
        ]

        if kind == Kinds.sale {
            params[DeeplinkParamKeys.amount] = intStr(amount)
            params[DeeplinkParamKeys.tipCollect] = boolStr(tipCollect)
            params[DeeplinkParamKeys.tipAmount] = intStr(tipAmount)
            params[DeeplinkParamKeys.originReferenceNum] = originReferenceNum
        }

        if kind == Kinds.refund {
            params[DeeplinkParamKeys.amount] = intStr(amount)
            params[DeeplinkParamKeys.originReferenceNum] = originReferenceNum
        }

        if kind == Kinds.cancel {
            params[DeeplinkParamKeys.amsID] = originTx
        }

        let url = buildDeeplink(path: path, params: params)
        openDeeplink(url) { errorResponse in
            self.sendEvent(
                kind: kind,
                transactionId: txId,
                response: errorResponse
            )
        }

        GpTomLog.i(
            "transaction() opened deeplink",
            ["kind": kind, "txId": txId, "url": url.absoluteString])
    }

    private func getState(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        sendEvent(
            kind: Kinds.state, transactionId: nil,
            response: .error(
                code: ResultCodes.unsupportedOnPlatform, message: "getState is not supported on iOS"
            ))
    }

    private func getDetail(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any] ?? [:]

        guard let txId = args[JsonKeys.transactionId] as? String, !txId.isEmpty else {
            sendMethodResult(
                result,
                .error(
                    code: ResultCodes.invalidArgument,
                    message: "\(JsonKeys.transactionId) is required"))
            return
        }

        sendMethodResult(result, .success(NSNull()))

        let path = deeplinkPathForKind(Kinds.detail).path
        var params: [String: String?] = [
            DeeplinkParamKeys.requestID: txId,
            DeeplinkParamKeys.redirectUrl: buildRedirectUrl(
                schemeUrl: redirectScheme, path: path),
        ]

        let url = buildDeeplink(path: path, params: params)
        openDeeplink(url) { errorResponse in
            self.sendEvent(
                kind: Kinds.detail,
                transactionId: txId,
                response: errorResponse
            )
        }

        GpTomLog.i(
            "getDetail() opened deeplink", ["txId": txId, "url": url.absoluteString])
    }

    public func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        guard let result = DeeplinkResult.from(url: url) else {
            sendEvent(
                kind: Kinds.info,
                transactionId: nil,
                response: .error(
                    code: ResultCodes.invalidDeeplink,
                    message: "Failed to parse DeeplinkResult"
                )
            )
            return true
        }

        var kind = Kinds.info
        var transactionId: String? = nil
        var clearPending = true
        var response: PluginResponse = .error(
            code: ResultCodes.internalError,
            message: "Unhandled result"
        )

        switch result {

        case .createTransaction(let tx, let refusal, let status, let error):
            kind = Kinds.sale
            transactionId = tx?.transactionID

            let data = tx.map { TransactionMapper.toMap($0) }

            response = toPluginResponse(
                status: status,
                refusal: refusal,
                error: error,
                successData: data
            )

        case .refundTransaction(let tx, let refusal, let status, let error):
            kind = Kinds.refund
            transactionId = tx?.transactionID

            let data = tx.map { TransactionMapper.toMap($0) }

            response = toPluginResponse(
                status: status,
                refusal: refusal,
                error: error,
                successData: data
            )

        case .cancelTransaction(let tx, let refusal, let status, let error):
            kind = Kinds.cancel
            transactionId = tx?.transactionID

            let data = tx.map { TransactionMapper.toMap($0) }

            response = toPluginResponse(
                status: status,
                refusal: refusal,
                error: error,
                successData: data
            )

        case .closeBatch(let batch, let status, let error):
            kind = Kinds.closeBatch
            clearPending = false

            let data = batch.map { BatchMapper.toMap($0) }

            response = toPluginResponse(
                status: status,
                refusal: nil,
                error: error,
                successData: data
            )

        case .status(let appStatus, let status):
            kind = Kinds.appStatus
            clearPending = false

            let data = appStatus.map { AppStatusMapper.toMap($0) }

            response = .success(data)

        case .login(let status, let error):
            kind = Kinds.login
            clearPending = false

            response = toPluginResponse(
                status: status,
                refusal: nil,
                error: error,
                successData: nil
            )

        case .logout(let status):
            kind = Kinds.logout
            clearPending = false

            response = toPluginResponse(
                status: status,
                refusal: nil,
                error: nil,
                successData: nil
            )

        case .changePassword(let status, let error):
            kind = Kinds.changePassword
            clearPending = false

            response = toPluginResponse(
                status: status,
                refusal: nil,
                error: error,
                successData: nil
            )
        }

        if clearPending {
            pendingStore.clear()
        }

        sendEvent(
            kind: kind,
            transactionId: transactionId,
            response: response
        )

        return true
    }

    private func sendEvent(kind: String, transactionId: String?, response: PluginResponse) {
        guard let sink = eventSink else { return }

        var payload: [String: Any] = [
            JsonKeys.kind: kind
        ]

        if let tx = transactionId {
            payload[JsonKeys.transactionId] = tx
        }

        payload.merge(response.toMap()) { _, new in new }

        runOnMain {
            sink(payload)
        }
    }

    private func sendMethodResult(_ result: @escaping FlutterResult, _ response: PluginResponse) {
        runOnMain {
            result(response.toMap())
        }
    }

    private func runOnMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    private func buildDeeplink(
        scheme: String = "gptom",
        path: String,
        params: [String: String?]
    ) -> URL {
        var components = URLComponents(string: "\(scheme)://\(path)")!

        let items = params.compactMap { key, value -> URLQueryItem? in
            guard let value, !value.isEmpty else { return nil }
            return URLQueryItem(name: key, value: value)
        }

        components.queryItems = items.isEmpty ? nil : items
        return components.url!
    }

    private func openDeeplink(
        _ url: URL,
        onError: @escaping (PluginResponse) -> Void
    ) {
        runOnMain {
            UIApplication.shared.open(url, options: [:]) { success in
                if !success {
                    onError(
                        .error(
                            code: ResultCodes.failed,
                            message: "Failed to open URL: \(url.absoluteString)"
                        )
                    )
                }
            }
        }
    }

    private func toPluginResponse(
        status: TaskStatus,
        refusal: RefusalCode?,
        error: DeeplinkError?,
        successData: Any?
    ) -> PluginResponse {

        if let data = successData {
            return .success(data)
        }

        if let error {
            return .error(
                code: ResultCodes.from(error),
                message: error.rawValue
            )
        }

        if status != .completed {
            return .error(
                code: ResultCodes.failed,
                message: status.rawValue
            )
        }

        if let refusal, !refusal.isApproved {
            return .error(
                code: ResultCodes.failed,
                message: refusal.rawValue
            )
        }

        return .error(
            code: ResultCodes.internalError,
            message: "No result data returned"
        )
    }

    private func deeplinkPathForKind(_ kind: String) -> DeeplinkPath {
        switch kind {
        case Kinds.sale: return .createTransaction
        case Kinds.cancel: return .cancelTransaction
        case Kinds.refund: return .refundTransaction
        case Kinds.closeBatch: return .closeBatch
        case Kinds.detail: return .transactionDetail
        default: return .result
        }
    }

    private func buildRedirectUrl(schemeUrl: String, path: String) -> String {
        let cleanPath = "/" + path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        if var components = URLComponents(string: schemeUrl) {
            components.path = cleanPath
            if let url = components.url?.absoluteString {
                return url
            }
        }

        let cleanScheme = schemeUrl.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return "\(cleanScheme)\(cleanPath)"
    }

    private func boolStr(_ v: Bool?) -> String? {
        guard let v else { return nil }
        return v ? "true" : "false"
    }

    private func intStr(_ v: Int?) -> String? { v.map(String.init) }
}
