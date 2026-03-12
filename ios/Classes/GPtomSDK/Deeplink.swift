import Foundation

public enum Deeplink: Sendable {
    case createTransaction(CreateTransactionParams)
    case cancelTransaction(CancelTransactionParams)
    case refundTransaction(RefundTransactionParams)
    case transactionDetail(TransactionDetailParams)
    case closeBatch(CloseBatchParams)
    case batchDetail(BatchDetailParams)
    case login(LoginParams)
    case logout(LogoutParams)
    case changePassword(ChangePasswordParams)
    case status(StatusParams)

    public var clientID: String? {
        switch self {
        case let .createTransaction(params):
            params.clientID
        case let .cancelTransaction(params):
            params.clientID
        case let .refundTransaction(params):
            params.clientID
        case let .closeBatch(params):
            params.clientID
        default:
            nil
        }
    }

    public var redirectUrl: String? {
        switch self {
        case let .createTransaction(params):
            params.redirectUrl
        case let .cancelTransaction(params):
            params.redirectUrl
        case let .refundTransaction(params):
            params.redirectUrl
        case let .status(params):
            params.redirectUrl
        case let .closeBatch(params):
            params.redirectUrl
        default:
            nil
        }
    }

    public static func from(url: URL) -> Deeplink? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let params = convertQueryToDictionary(queryItems: components?.queryItems ?? [])

        let urlString = url.absoluteString

        if urlString.contains("transaction/create") {
            return CreateTransactionParams(params: params).flatMap { .createTransaction($0) }
        } else if urlString.contains("transaction/cancel") {
            return CancelTransactionParams(params: params).flatMap { .cancelTransaction($0) }
        } else if urlString.contains("transaction/detail") {
            return TransactionDetailParams(params: params).flatMap { .transactionDetail($0) }
        } else if urlString.contains("transaction/refund") {
            return RefundTransactionParams(params: params).flatMap { .refundTransaction($0) }
        } else if urlString.contains("batch/close") {
            return CloseBatchParams(params: params).flatMap { .closeBatch($0) }
        } else if urlString.contains("batch/detail") {
            return BatchDetailParams(params: params).flatMap { .batchDetail($0) }
        } else if urlString.contains("login") {
            return LoginParams(params: params).flatMap { .login($0) }
        } else if urlString.contains("logout") {
            return LogoutParams(params: params).flatMap { .logout($0) }
        } else if urlString.contains("change-password") {
            return ChangePasswordParams(params: params).flatMap { .changePassword($0) }
        } else if urlString.contains("status") {
            return StatusParams(params: params).flatMap { .status($0) }
        } else {
            return nil
        }
    }

    private static func convertQueryToDictionary(queryItems: [URLQueryItem]) -> [String: String] {
        var items = [String: String]()

        for item in queryItems {
            items[item.name] = item.value?.removingPercentEncoding
        }

        return items
    }

}

/// gptom://transaction/refund
public typealias RefundTransactionParams = CreateTransactionParams

/// gptom://transaction/create
public struct CreateTransactionParams: Sendable {
    /// optional id that can be used to access transaction detail instead of amsId.
    /// can only be used locally on the device that created the transaction
    public let requestID: String?

    public let amount: Amount
    public let clientID: String?
    public let referenceNumber: String?
    public let printByPaymentApp: Bool?
    public let tipAmount: Amount?
    public let redirectUrl: String?
    public let tipCollect: Bool?
    public let transactionType: TransactionType?

    public let preferableReceiptType: ReceiptOption?
    public let clientPhone: String?
    public let clientEmail: String?
    public let orderId: String?

    public init(
        requestID: String? = nil,
        amount: Amount,
        clientID: String? = nil,
        referenceNumber: String? = nil,
        printByPaymentApp: Bool? = nil,
        tipAmount: Amount? = nil,
        redirectUrl: String? = nil,
        tipCollect: Bool? = nil,
        preferableReceiptType: ReceiptOption? = nil,
        clientPhone: String? = nil,
        clientEmail: String? = nil,
        orderId: String? = nil,
        transactionType: TransactionType? = nil
    ) {
        self.requestID = requestID
        self.amount = amount
        self.referenceNumber = referenceNumber
        self.orderId = orderId
        self.clientID = clientID
        self.printByPaymentApp = printByPaymentApp
        self.tipAmount = tipAmount
        self.redirectUrl = redirectUrl
        self.tipCollect = tipCollect
        self.preferableReceiptType = preferableReceiptType
        self.clientPhone = clientPhone
        self.clientEmail = clientEmail
        self.transactionType = transactionType
    }

    init?(params: [String: String]) {
        guard let amount = params["amount"].flatMap({ Int64($0) }) else {
            return nil
        }

        self.amount = Decimal(amount) / 100

        self.requestID = params["requestID"]
        self.clientID = params["clientID"]
        self.referenceNumber = params["originReferenceNum"]
        self.printByPaymentApp = params["printByPaymentApp"].flatMap { Bool($0) }
        self.tipAmount = params["tipAmount"].flatMap { Decimal(Int64($0) ?? 0) / 100 }
        self.redirectUrl = params["redirectUrl"]
        self.tipCollect = params["tipCollect"].flatMap { Bool($0) }
        self.preferableReceiptType = params["preferableReceiptType"].flatMap { ReceiptOption(rawValue: $0) }
        self.clientPhone = params["clientPhone"]
        self.clientEmail = params["clientEmail"]
        self.orderId = nil
        self.transactionType = params["transactionType"].flatMap { TransactionType(rawValue: $0) }
    }
}

/// gptom://transaction/cancel
public struct CancelTransactionParams: Sendable {
    /// optional id that can be used to access transaction detail instead of amsId.
    /// can only be used locally on the device that created the transaction
    public let requestID: String?

    public let clientID: String?
    public let amsID: String
    public let redirectUrl: String?
    public let printByPaymentApp: Bool?

    public let preferableReceiptType: ReceiptOption?
    public let clientPhone: String?
    public let clientEmail: String?

    public init(
        requestID: String? = nil,
        clientID: String? = nil,
        amsID: String,
        printByPaymentApp: Bool? = nil,
        redirectUrl: String? = nil,
        preferableReceiptType: ReceiptOption? = nil,
        clientPhone: String? = nil,
        clientEmail: String? = nil,
        orderId: String? = nil
    ) {
        self.requestID = requestID
        self.clientID = clientID
        self.printByPaymentApp = printByPaymentApp
        self.amsID = amsID
        self.redirectUrl = redirectUrl
        self.preferableReceiptType = preferableReceiptType
        self.clientPhone = clientPhone
        self.clientEmail = clientEmail
    }

    init?(params: [String: String]) {
        self.clientID = params["clientID"]

        guard let amsID = params["amsID"] else {
            return nil
        }

        self.amsID = amsID

        self.requestID = params["requestID"]

        self.redirectUrl = params["redirectUrl"]
        self.printByPaymentApp = params["printByPaymentApp"].flatMap { Bool($0) }

        self.preferableReceiptType = params["preferableReceiptType"].flatMap { ReceiptOption(rawValue: $0) }
        self.clientPhone = params["clientPhone"]
        self.clientEmail = params["clientEmail"]
    }
}

/// gptom://transaction/detail
public struct TransactionDetailParams: Sendable {
    public let amsID: String?
    public let requestID: String?

    public init?(params: [String: String]) {
        self.amsID = params["amsID"]
        self.requestID = params["requestID"]

        if amsID == nil, requestID == nil {
            return nil
        }
    }

    public init(amsID: String? = nil, requestID: String? = nil) {
        self.amsID = amsID
        self.requestID = requestID
    }
}

/// gptom://batch/close
public struct CloseBatchParams: Sendable {
    public let clientID: String?
    public let redirectUrl: String?

    public let printByPaymentApp: Bool?
    public let preferableReceiptType: ReceiptOption?
    public let clientPhone: String?
    public let clientEmail: String?

    public init(
        clientID: String?,
        redirectUrl: String?,
        printByPaymentApp: Bool?,
        preferableReceiptType: ReceiptOption?,
        clientPhone: String?,
        clientEmail: String?
    ) {
        self.clientID = clientID
        self.redirectUrl = redirectUrl
        self.printByPaymentApp = printByPaymentApp
        self.preferableReceiptType = preferableReceiptType
        self.clientEmail = clientEmail
        self.clientPhone = clientPhone
    }

    init?(params: [String: String]) {
        self.clientID = params["clientID"]
        self.redirectUrl = params["redirectUrl"]

        self.printByPaymentApp = params["printByPaymentApp"].flatMap { Bool($0) }
        self.preferableReceiptType = params["preferableReceiptType"].flatMap { ReceiptOption(rawValue: $0) }
        self.clientPhone = params["clientPhone"]
        self.clientEmail = params["clientEmail"]
    }
}

/// gptom://batch/detail
public struct BatchDetailParams: Sendable {
    public let amsID: String

    init?(params: [String: String]) {
        guard let amsID = params["amsID"] else {
            return nil
        }

        self.amsID = amsID
    }
}

public struct LogoutParams: Sendable {
    public let redirectUrl: String?

    init?(params: [String: String]) {
        self.redirectUrl = params["redirectUrl"]
    }
}

/// gptom://login
public struct LoginParams: Sendable {
    public let username: String
    public let password: String
    public let tid: String
    public let redirectUrl: String?

    init?(params: [String: String]) {
        guard
            let username = params["username"],
            let password = params["password"],
            let tid = params["tid"]
        else {
            return nil
        }

        self.username = username
        self.password = password
        self.tid = tid
        self.redirectUrl = params["redirectUrl"]
    }
}

public struct ChangePasswordParams: Sendable {
    public let username: String
    public let password: String
    public let newPassword: String
    public let code: String?
    public let redirectUrl: String?

    init?(params: [String: String]) {
        guard
            let username = params["username"],
            let password = params["password"],
            let newPassword = params["newPassword"]
        else {
            return nil
        }

        self.username = username
        self.password = password
        self.newPassword = newPassword
        self.code = params["code"].flatMap { $0.isEmpty ? nil : $0 }
        self.redirectUrl = params["redirectUrl"]
    }
}

/// gptom://status
public struct StatusParams: Sendable {
    public let redirectUrl: String

    init?(params: [String: String]) {
        guard
            let redirectUrl = params["redirectUrl"]
        else {
            return nil
        }

        self.redirectUrl = redirectUrl
    }
}
