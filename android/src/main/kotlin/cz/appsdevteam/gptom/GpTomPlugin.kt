package cz.appsdevteam.gptom

import android.content.Context
import android.os.Handler
import android.os.Looper
import cn.nexgo.smartconnect.listener.IInquireResultListener
import cn.nexgo.smartconnect.listener.IStateResultListener
import cn.nexgo.smartconnect.listener.ITransactionRegisterListener
import cn.nexgo.smartconnect.listener.ITransactionResultListener
import com.google.gson.Gson
import cz.appsdevteam.gptom.core.Channels
import cz.appsdevteam.gptom.core.JsonKeys
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import cz.appsdevteam.gptom.mappers.InquireResultMapper
import cz.appsdevteam.gptom.mappers.TransactionResultMapper
import cz.appsdevteam.gptom.mappers.RegisterResultMapper
import cz.appsdevteam.gptom.mappers.StateResultMapper
import cz.appsdevteam.gptom.mappers.BatchMapper
import cz.appsdevteam.gptom.models.PluginResponse
import cz.appsdevteam.gptom.models.TransactionType
import cz.appsdevteam.gptom.models.ResultCodes
import cz.appsdevteam.gptom.storage.PendingStore
import cz.appsdevteam.gptom.support.GpTomLog
import kotlin.jvm.java

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

    private val pendingBatchResults = mutableMapOf<String, Map<String, Any?>>()
    private val cancelledPolls = mutableSetOf<String>()
    private val activePollKinds = mutableMapOf<String, String>()

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
                    response = PluginResponse.Error(ResultCodes.INTERNAL_ERROR, msg)
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
            "cancelPolling" -> cancelPolling(call, result)
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
                            GpTomLog.i("onRegisterV2Result", resultJson)
                            if (resultJson.isNullOrBlank()) {
                                sendMethodResult(result, PluginResponse.Error(ResultCodes.INTERNAL_ERROR, "Register returned empty result"))
                                return
                            }

                            val parsed = try {
                                gson.fromJson(resultJson, cn.nexgo.smartconnect.model.RegisterResultV2Entity::class.java)
                            } catch (e: Exception) {
                                sendMethodResult(result, PluginResponse.Error(ResultCodes.INTERNAL_ERROR, "Failed to parse: ${e.message}"))
                                return
                            }

                            val txId = parsed.transactionId
                            if (txId.isNullOrBlank()) {
                                sendMethodResult(result, PluginResponse.Error(ResultCodes.INTERNAL_ERROR, "TransactionId is null/blank"))
                                return
                            }

                            if (persist) pendingStore.save(txId, originRef, amsId = null)

                            sendMethodResult(result, PluginResponse.Success(RegisterResultMapper.toMap(parsed, originRef)))
                            serviceClient.touch()
                        }
                    })
                } catch (e: Exception) {
                    sendMethodResult(result, PluginResponse.Error(ResultCodes.INTERNAL_ERROR, "register failed: ${e.message}"))
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
            sendMethodResult(result, PluginResponse.Error(ResultCodes.INVALID_ARGUMENT, "${JsonKeys.transactionId} is required"))
            return
        }
        if (txType == null) {
            sendMethodResult(result, PluginResponse.Error(ResultCodes.INVALID_ARGUMENT, "Unknown or missing ${JsonKeys.transactionType}"))
            return
        }

        val amountLong = (args[JsonKeys.amount] as? Number)?.toLong()
        if ((txType == TransactionType.SALE || txType == TransactionType.REFUND) && (amountLong == null || amountLong < 0)) {
            sendMethodResult(result, PluginResponse.Error(ResultCodes.INVALID_ARGUMENT, "Amount required for sale/refund"))
            return
        }

        if (txType == TransactionType.CANCEL) {
            val cancelMode = (args[JsonKeys.cancelMode] as? Number)?.toInt()
            if (cancelMode == null || (cancelMode != 1 && cancelMode != 2)) {
                sendMethodResult(result, PluginResponse.Error(ResultCodes.INVALID_ARGUMENT, "CancelMode must be 1 or 2"))
                return
            }
            if (cancelMode == 2 && (args[JsonKeys.originTransactionId] as? String).isNullOrBlank()) {
                sendMethodResult(result, PluginResponse.Error(ResultCodes.INVALID_ARGUMENT, "OriginTransactionId required for mode 2"))
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
                            GpTomLog.i("onTransactionV2Result", resultJson)
                            // Only closeBatch needs the V2 callback data (batch totals).
                            // Sale/refund/cancel rely entirely on state polling + inquire.
                            if (txType != TransactionType.CLOSE_BATCH) return

                            try {
                                val parsed = gson.fromJson(resultJson, cn.nexgo.smartconnect.model.TransactionResultV2Entity::class.java)
                                runOnMain { pendingBatchResults[txId] = BatchMapper.toMap(parsed) }
                            } catch (e: Exception) {
                                GpTomLog.e("Failed to parse V2 batch result: ${e.message}")
                            }
                        }
                    })

                    activePollKinds[txId] = txType.kind
                    pollTransactionState(svc, txType, txId, startedAtMs = System.currentTimeMillis())
                } catch (e: Exception) {
                    serviceClient.markInFlightEnd()
                    sendEvent(txType.kind, txId, response = PluginResponse.Error(ResultCodes.INTERNAL_ERROR, "Failed: ${e.message}"))
                }
            },
            onError = { error -> sendEvent(txType.kind, txId, response = error) }
        )
    }

    private fun pollTransactionState(
        svc: cn.nexgo.smartconnect.ISmartconnectService,
        txType: TransactionType,
        txId: String,
        startedAtMs: Long,
    ) {
        if (cancelledPolls.remove(txId)) {
            activePollKinds.remove(txId)
            pendingBatchResults.remove(txId)
            sendEvent(txType.kind, txId, PluginResponse.Error(ResultCodes.CANCELLED, "Polling cancelled"))
            serviceClient.markInFlightEnd()
            return
        }

        if (System.currentTimeMillis() - startedAtMs > POLL_TIMEOUT_MS) {
            activePollKinds.remove(txId)
            sendEvent(txType.kind, txId, PluginResponse.Error(ResultCodes.TIMEOUT, "Transaction polling timed out"))
            serviceClient.markInFlightEnd()
            return
        }

        try {
            svc.stateRequest(txId, object : IStateResultListener.Stub() {
                override fun onStateResult(resultJson: String?) {
                    GpTomLog.i("polling onStateResult", resultJson)

                    val state: Int? = try {
                        gson.fromJson(resultJson, cn.nexgo.smartconnect.model.StateResultEntity::class.java)?.state
                    } catch (_: Exception) {
                        null
                    }

                    when (state) {
                        STATE_COMPLETED -> handleCompletedState(svc, txType, txId)
                        STATE_CANCELLED -> {
                            activePollKinds.remove(txId)
                            sendEvent(txType.kind, txId, PluginResponse.Error(ResultCodes.FAILED, "Transaction cancelled"))
                            serviceClient.markInFlightEnd()
                        }
                        STATE_ERROR -> {
                            activePollKinds.remove(txId)
                            sendEvent(txType.kind, txId, PluginResponse.Error(ResultCodes.FAILED, "Transaction error"))
                            serviceClient.markInFlightEnd()
                        }
                        else -> {
                            mainHandler.postDelayed({
                                pollTransactionState(svc, txType, txId, startedAtMs)
                            }, POLL_INTERVAL_MS)
                        }
                    }
                }
            })
        } catch (e: Exception) {
            activePollKinds.remove(txId)
            sendEvent(txType.kind, txId, PluginResponse.Error(ResultCodes.INTERNAL_ERROR, "State poll failed: ${e.message}"))
            serviceClient.markInFlightEnd()
        }
    }

    private fun cancelPolling(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as? Map<*, *> ?: emptyMap<Any, Any>()
        val txId = args[JsonKeys.transactionId] as? String

        if (txId.isNullOrBlank()) {
            sendMethodResult(result, PluginResponse.Error(ResultCodes.INVALID_ARGUMENT, "${JsonKeys.transactionId} is required"))
            return
        }

        if (activePollKinds.containsKey(txId)) {
            cancelledPolls.add(txId)
            sendMethodResult(result, PluginResponse.Success(null))
        } else {
            sendMethodResult(result, PluginResponse.Error(ResultCodes.FAILED, "No active polling for transactionId"))
        }
    }

    private fun handleCompletedState(
        svc: cn.nexgo.smartconnect.ISmartconnectService,
        txType: TransactionType,
        txId: String,
        retries: Int = 0,
    ) {
        if (cancelledPolls.remove(txId)) {
            activePollKinds.remove(txId)
            pendingBatchResults.remove(txId)
            sendEvent(txType.kind, txId, PluginResponse.Error(ResultCodes.CANCELLED, "Polling cancelled"))
            serviceClient.markInFlightEnd()
            return
        }

        if (txType == TransactionType.CLOSE_BATCH) {
            val cached = pendingBatchResults.remove(txId)
            if (cached != null) {
                activePollKinds.remove(txId)
                sendEvent(txType.kind, txId, PluginResponse.Success(cached))
                serviceClient.markInFlightEnd()
                return
            }
            // V2 callback may not have arrived yet — wait briefly, up to ~2s
            if (retries < BATCH_RESULT_MAX_RETRIES) {
                mainHandler.postDelayed({
                    handleCompletedState(svc, txType, txId, retries + 1)
                }, POLL_INTERVAL_MS)
                return
            }
            activePollKinds.remove(txId)
            sendEvent(txType.kind, txId, PluginResponse.Success(emptyMap<String, Any?>()))
            serviceClient.markInFlightEnd()
            return
        }

        pendingStore.clear()

        try {
            svc.TransactionInquire(txId, object : IInquireResultListener.Stub() {
                override fun onInquireResult(p0: cn.nexgo.smartconnect.model.InquireResultEntity) {
                    activePollKinds.remove(txId)
                    try {
                        val mapped = InquireResultMapper.toMap(p0)
                        GpTomLog.i("handleCompletedState inquire result", mapped)
                        sendEvent(txType.kind, txId, PluginResponse.Success(mapped))
                    } catch (e: Exception) {
                        sendEvent(txType.kind, txId, PluginResponse.Error(ResultCodes.INTERNAL_ERROR, "Inquire mapping failed: ${e.message}"))
                    } finally {
                        serviceClient.markInFlightEnd()
                    }
                }
            })
        } catch (e: Exception) {
            activePollKinds.remove(txId)
            sendEvent(txType.kind, txId, PluginResponse.Error(ResultCodes.INTERNAL_ERROR, "Inquire call failed: ${e.message}"))
            serviceClient.markInFlightEnd()
        }
    }

    private fun getState(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as? Map<*, *> ?: emptyMap<Any, Any>()
        val txId = args[JsonKeys.transactionId] as? String ?: return sendMethodResult(result, PluginResponse.Error(ResultCodes.INVALID_ARGUMENT, "txId missing"))

        sendMethodResult(result, PluginResponse.Success(null))

        serviceClient.ensureBoundAsync(
            onReady = { svc ->
                try {
                    serviceClient.markInFlightStart()
                    svc.stateRequest(txId, object : IStateResultListener.Stub() {
                        override fun onStateResult(resultJson: String?) {
                            GpTomLog.i("onStateResult", resultJson)
                            try {
                                if (resultJson.isNullOrBlank()) {
                                    sendEvent(KIND_STATE, txId, response = PluginResponse.Error(ResultCodes.INTERNAL_ERROR, "Empty result"))
                                    return
                                }
                                val parsed = gson.fromJson(resultJson, cn.nexgo.smartconnect.model.StateResultEntity::class.java)
                                sendEvent(KIND_STATE, txId, response = PluginResponse.Success(StateResultMapper.toMap(parsed)))
                                serviceClient.touch()
                            } catch (e: Exception) {
                                sendEvent(KIND_STATE, txId, response = PluginResponse.Error(ResultCodes.INTERNAL_ERROR, e.message?: "Unknown error"))
                            } finally {
                                serviceClient.markInFlightEnd()
                            }
                        }
                    })
                } catch (e: Exception) {
                    serviceClient.markInFlightEnd()
                    sendEvent(KIND_STATE, txId, response = PluginResponse.Error(ResultCodes.INTERNAL_ERROR, e.message?: "Unknown error"))
                }
            },
            onError = { error -> sendEvent(KIND_STATE, txId, response = error) }
        )
    }

    private fun getDetail(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as? Map<*, *> ?: emptyMap<Any, Any>()
        val txId = args[JsonKeys.transactionId] as? String ?: return sendMethodResult(result, PluginResponse.Error(ResultCodes.INVALID_ARGUMENT, "txId missing"))

        sendMethodResult(result, PluginResponse.Success(null))

        serviceClient.ensureBoundAsync(
            onReady = { svc ->
                try {
                    serviceClient.markInFlightStart()
                    svc.TransactionInquire(txId, object : IInquireResultListener.Stub() {
                        override fun onInquireResult(p0: cn.nexgo.smartconnect.model.InquireResultEntity) {
                            GpTomLog.i("onInquireResult", p0.toString())
                            try {
                                sendEvent(KIND_DETAIL, txId, response = PluginResponse.Success(InquireResultMapper.toMap(p0)))
                                serviceClient.touch()
                            } catch (e: Exception) {
                                sendEvent(KIND_DETAIL, txId, response = PluginResponse.Error(ResultCodes.INTERNAL_ERROR, e.message?: "Unknown error"))
                            } finally {
                                serviceClient.markInFlightEnd()
                            }
                        }
                    })
                } catch (e: Exception) {
                    serviceClient.markInFlightEnd()
                    sendEvent(KIND_DETAIL, txId, response = PluginResponse.Error(ResultCodes.INTERNAL_ERROR, e.message?: "Unknown error"))
                }
            },
            onError = { error -> sendEvent(KIND_DETAIL, txId, response = error) }
        )
    }

    private fun validatePluginState(): PluginResponse.Error? {
        if (!isInitialized) return PluginResponse.Error(ResultCodes.NOT_INITIALIZED, "Call GpTomManager.init() first")
        if (!serviceClient.isInstalled()) return PluginResponse.Error(ResultCodes.NOT_INSTALLED, "GP tom app is not installed")
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
        GpTomLog.i("sendEvent", payload)
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
        const val KIND_APP_STATUS = "appStatus"

        private const val POLL_INTERVAL_MS = 500L
        private const val POLL_TIMEOUT_MS = 5L * 60L * 1000L
        private const val BATCH_RESULT_MAX_RETRIES = 4

        private const val STATE_COMPLETED = 6
        private const val STATE_CANCELLED = 7
        private const val STATE_ERROR = 8
    }
}