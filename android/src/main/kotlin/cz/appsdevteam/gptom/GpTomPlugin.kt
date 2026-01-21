package cz.appsdevteam.gptom

import android.content.Context
import android.os.Handler
import android.os.Looper
import cn.nexgo.smartconnect.listener.IInquireResultListener
import cn.nexgo.smartconnect.listener.IStateResultListener
import cn.nexgo.smartconnect.listener.ITransactionRegisterListener
import cn.nexgo.smartconnect.listener.ITransactionResultListener
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import cz.appsdevteam.gptom.mappers.InquireResultMapper
import cz.appsdevteam.gptom.mappers.TransactionResultMapper
import cz.appsdevteam.gptom.mappers.RegisterResultMapper
import cz.appsdevteam.gptom.mappers.StateResultMapper
import cz.appsdevteam.gptom.models.PluginResponse
import cz.appsdevteam.gptom.models.TransactionType

class GpTomPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private lateinit var appContext: Context
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null

    private var isInitialized = false
    private var isDevelopment = false
    private var idleDisconnectMs: Long = 120_000
    private var debugLogs: Boolean = false

    private lateinit var pendingStore: PendingStore
    private lateinit var serviceClient: ServiceClient
    private val gson = Gson()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext
        GpTomLog.configure(enabled = false)

        pendingStore = PendingStore(appContext)
        serviceClient = ServiceClient(
            ctx = appContext,
            isDevProvider = { isDevelopment },
            idleDisconnectMsProvider = { idleDisconnectMs },
            onDisconnected = { msg ->
                sendEvent(
                    kind = KIND_INFO,
                    transactionId = null,
                    response = PluginResponse.Error("internalError", msg)
                )
            },
        )

        methodChannel = MethodChannel(binding.binaryMessenger, Channels.METHODS)
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, Channels.EVENTS)
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        serviceClient.unbindNow()
        eventSink = null
        GpTomLog.configure(enabled = false)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "init") {
            handleInit(call, result)
            return
        }

        val validationError = validatePluginState()
        if (validationError != null) {
            sendMethodResult(result, validationError)
            return
        }

        when (call.method) {
            "isInstalled" -> sendMethodResult(result, PluginResponse.Success(serviceClient.isInstalled()))
            "register" -> register(call, result)
            "transaction" -> transaction(call, result)
            "getState" -> getState(call, result)
            "getDetail" -> getDetail(call, result)
            "getPending" -> sendMethodResult(result, PluginResponse.Success(pendingStore.read()))
            "clearPending" -> {
                pendingStore.clear()
                sendMethodResult(result, PluginResponse.Success(null))
            }
            else -> result.notImplemented()
        }
    }

    private fun handleInit(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as? Map<*, *> ?: emptyMap<Any, Any>()
        isDevelopment = args[JsonKeys.isDevelopment] as? Boolean ?: false
        debugLogs = args[JsonKeys.debugLogs] as? Boolean ?: false
        isInitialized = true

        GpTomLog.configure(enabled = debugLogs)
        GpTomLog.i("init()", data = mapOf("args" to call.arguments))

        sendMethodResult(result, PluginResponse.Success(null))
    }

    private fun register(call: MethodCall, result: MethodChannel.Result) {
        GpTomLog.i("register() called", data = mapOf("args" to call.arguments))

        val args = call.arguments as? Map<*, *> ?: emptyMap<Any, Any>()
        val originRef = args[JsonKeys.originReferenceNum] as? String
        val clientId = args[JsonKeys.clientId] as? String
        val persist = args[JsonKeys.persistPending] as? Boolean ?: true

        serviceClient.ensureBoundAsync(
            onReady = { svc ->
                try {
                    val entity = cn.nexgo.smartconnect.model.RegisterEntity().apply {
                        if (!clientId.isNullOrBlank()) clientID = clientId
                    }

                    svc.transactionRegisterV2(gson.toJson(entity), object : ITransactionRegisterListener.Stub() {
                        override fun onRegisterResult(p0: cn.nexgo.smartconnect.model.RegisterResultEntity?) {}

                        override fun onRegisterV2Result(resultJson: String?) {
                            if (resultJson.isNullOrBlank()) {
                                sendMethodResult(result, PluginResponse.Error("internalError", "Register returned empty result"))
                                return
                            }

                            val parsed = try {
                                gson.fromJson(resultJson, cn.nexgo.smartconnect.model.RegisterResultV2Entity::class.java)
                            } catch (e: Exception) {
                                sendMethodResult(result, PluginResponse.Error("internalError", "Failed to parse: ${e.message}"))
                                return
                            }

                            val txId = parsed.transactionId
                            if (txId.isNullOrBlank()) {
                                sendMethodResult(result, PluginResponse.Error("internalError", "TransactionId is null/blank"))
                                return
                            }

                            if (persist) pendingStore.save(txId, originRef, amsId = null)

                            sendMethodResult(result, PluginResponse.Success(RegisterResultMapper.toMap(parsed, originRef)))
                            serviceClient.touch()
                        }
                    })
                } catch (e: Exception) {
                    sendMethodResult(result, PluginResponse.Error("internalError", "register failed: ${e.message}"))
                }
            },
            onError = { error -> sendMethodResult(result, error) }
        )
    }

    private fun transaction(call: MethodCall, result: MethodChannel.Result) {
        GpTomLog.i("transaction() called", data = mapOf("args" to call.arguments))

        val args = call.arguments as? Map<*, *> ?: emptyMap<Any, Any>()
        val txId = args[JsonKeys.transactionId] as? String
        val typeInt = (args[JsonKeys.transactionType] as? Number)?.toInt()
        val txType = TransactionType.fromInt(typeInt)

        if (txId.isNullOrBlank()) {
            sendMethodResult(result, PluginResponse.Error("invalidArgument", "${JsonKeys.transactionId} is required"))
            return
        }
        if (txType == null) {
            sendMethodResult(result, PluginResponse.Error("invalidArgument", "Unknown or missing ${JsonKeys.transactionType}"))
            return
        }

        val amountLong = (args[JsonKeys.amount] as? Number)?.toLong()
        if ((txType == TransactionType.SALE || txType == TransactionType.REFUND) && (amountLong == null || amountLong < 0)) {
            sendMethodResult(result, PluginResponse.Error("invalidArgument", "Amount required for sale/refund"))
            return
        }

        if (txType == TransactionType.CANCEL) {
            val cancelMode = (args[JsonKeys.cancelMode] as? Number)?.toInt()
            if (cancelMode == null || (cancelMode != 1 && cancelMode != 2)) {
                sendMethodResult(result, PluginResponse.Error("invalidArgument", "CancelMode must be 1 or 2"))
                return
            }
            if (cancelMode == 2 && (args[JsonKeys.originTransactionId] as? String).isNullOrBlank()) {
                sendMethodResult(result, PluginResponse.Error("invalidArgument", "OriginTransactionId required for mode 2"))
                return
            }
        }

        sendMethodResult(result, PluginResponse.Success(null))

        serviceClient.ensureBoundAsync(
            onReady = { svc ->
                try {
                    serviceClient.markInFlightStart()

                    val entity = cn.nexgo.smartconnect.model.TransactionRequestV2Entity().apply {
                        transactionID = txId
                        transactionType = txType.code
                        (args[JsonKeys.clientId] as? String)?.takeIf { it.isNotBlank() }?.let { clientID = it }
                        printByPaymentApp = (args[JsonKeys.printByPaymentApp] as? Boolean) ?: true
                        tipCollect = args[JsonKeys.tipCollect] as? Boolean
                        tipAmount = (args[JsonKeys.tipAmount] as? Number)?.toLong()
                        originReferenceNum = args[JsonKeys.originReferenceNum] as? String
                        if (amountLong != null) amount = amountLong
                        currencyCode = (args[JsonKeys.currencyCode] as? String)

                        paymentMethod = (args[JsonKeys.paymentMethod] as? String)?.let { pm ->
                            try { cn.nexgo.smartconnect.model.PaymentMethod.valueOf(pm) } catch (_: Throwable) { null }
                        }

                        if (txType == TransactionType.CANCEL) {
                            cancelMode = (args[JsonKeys.cancelMode] as? Number)?.toInt()
                            originTransactionID = args[JsonKeys.originTransactionId] as? String
                        }
                    }

                    svc.transactionRequestV2(gson.toJson(entity), object : ITransactionResultListener.Stub() {
                        override fun onTransactionResult(p0: cn.nexgo.smartconnect.model.TransactionResultEntity?) {}

                        override fun onTransactionV2Result(resultJson: String?) {
                            try {
                                val parsed = gson.fromJson(resultJson, cn.nexgo.smartconnect.model.TransactionResultV2Entity::class.java)
                                if (txType != TransactionType.CLOSE_BATCH) pendingStore.clear()

                                sendEvent(txType.kind, txId, response = PluginResponse.Success(TransactionResultMapper.toMap(parsed)))
                            } catch (e: Exception) {
                                sendEvent(txType.kind, txId, response = PluginResponse.Error("internalError", "Parse error: ${e.message}"))
                            } finally {
                                serviceClient.markInFlightEnd()
                            }
                        }
                    })
                } catch (e: Exception) {
                    serviceClient.markInFlightEnd()
                    sendEvent(txType.kind, txId, response = PluginResponse.Error("internalError", "Failed: ${e.message}"))
                }
            },
            onError = { error -> sendEvent(txType.kind, txId, response = error) }
        )
    }

    private fun getState(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as? Map<*, *> ?: emptyMap<Any, Any>()
        val txId = args[JsonKeys.transactionId] as? String ?: return sendMethodResult(result, PluginResponse.Error("invalidArgument", "txId missing"))

        sendMethodResult(result, PluginResponse.Success(null))

        serviceClient.ensureBoundAsync(
            onReady = { svc ->
                try {
                    serviceClient.markInFlightStart()
                    svc.stateRequest(txId, object : IStateResultListener.Stub() {
                        override fun onStateResult(resultJson: String?) {
                            try {
                                if (resultJson.isNullOrBlank()) {
                                    sendEvent(KIND_STATE, txId, response = PluginResponse.Error("internalError", "Empty result"))
                                    return
                                }
                                val parsed = gson.fromJson(resultJson, cn.nexgo.smartconnect.model.StateResultEntity::class.java)
                                sendEvent(KIND_STATE, txId, response = PluginResponse.Success(StateResultMapper.toMap(parsed)))
                                serviceClient.touch()
                            } catch (e: Exception) {
                                sendEvent(KIND_STATE, txId, response = PluginResponse.Error("internalError", e.message?: "Unknown error"))
                            } finally {
                                serviceClient.markInFlightEnd()
                            }
                        }
                    })
                } catch (e: Exception) {
                    serviceClient.markInFlightEnd()
                    sendEvent(KIND_STATE, txId, response = PluginResponse.Error("internalError", e.message?: "Unknown error"))
                }
            },
            onError = { error -> sendEvent(KIND_STATE, txId, response = error) }
        )
    }

    private fun getDetail(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as? Map<*, *> ?: emptyMap<Any, Any>()
        val txId = args[JsonKeys.transactionId] as? String ?: return sendMethodResult(result, PluginResponse.Error("invalidArgument", "txId missing"))

        sendMethodResult(result, PluginResponse.Success(null))

        serviceClient.ensureBoundAsync(
            onReady = { svc ->
                try {
                    serviceClient.markInFlightStart()
                    svc.TransactionInquire(txId, object : IInquireResultListener.Stub() {
                        override fun onInquireResult(p0: cn.nexgo.smartconnect.model.InquireResultEntity) {
                            try {
                                sendEvent(KIND_DETAIL, txId, response = PluginResponse.Success(InquireResultMapper.toMap(p0)))
                                serviceClient.touch()
                            } catch (e: Exception) {
                                sendEvent(KIND_DETAIL, txId, response = PluginResponse.Error("internalError", e.message?: "Unknown error"))
                            } finally {
                                serviceClient.markInFlightEnd()
                            }
                        }
                    })
                } catch (e: Exception) {
                    serviceClient.markInFlightEnd()
                    sendEvent(KIND_DETAIL, txId, response = PluginResponse.Error("internalError", e.message?: "Unknown error"))
                }
            },
            onError = { error -> sendEvent(KIND_DETAIL, txId, response = error) }
        )
    }

    private fun validatePluginState(): PluginResponse.Error? {
        if (!isInitialized) return PluginResponse.Error("notInitialized", "Call GpTomManager.init() first")
        if (!serviceClient.isInstalled()) return PluginResponse.Error("notInstalled", "GP tom app is not installed")
        return null
    }

    private fun sendEvent(kind: String, transactionId: String?, response: PluginResponse) {
        val sink = eventSink ?: run {
            GpTomLog.w("Event skipped (no sink)", data = mapOf("kind" to kind))
            return
        }
        val payload = mutableMapOf<String, Any?>().apply {
            put(JsonKeys.kind, kind)
            transactionId?.let { put(JsonKeys.transactionId, it) }
            putAll(response.toMap())
        }
        runOnMain { sink.success(payload) }
    }

    private fun sendMethodResult(result: MethodChannel.Result, response: PluginResponse) {
        runOnMain { result.success(response.toMap()) }
    }

    private fun runOnMain(block: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) block() else mainHandler.post(block)
    }

    companion object {
        private const val TAG = "ADT_GP_TOM"

        const val KIND_INFO = "info"
        const val KIND_STATE = "state"
        const val KIND_DETAIL = "detail"
    }
}