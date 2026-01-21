package cz.appsdevteam.gptom

import android.content.*
import android.content.pm.PackageManager
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import cn.nexgo.smartconnect.ISmartconnectService
import cz.appsdevteam.gptom.models.PluginResponse

class ServiceClient(
    private val ctx: Context,
    private val isDevProvider: () -> Boolean,
    private val idleDisconnectMsProvider: () -> Long,
    private val onDisconnected: (String) -> Unit,
) {
    private val packageNameProd = "com.globalpayments.atom"
    private val packageNameDev = "com.globalpayments.atom.dev"
    private val serviceClassName = "com.globalpayments.atom.data.external.api.NexgoAPIService"

    private var connection: ServiceConnection? = null
    private var service: ISmartconnectService? = null

    private var isBinding = false
    private val pendingCallbacks = mutableListOf<(ISmartconnectService) -> Unit>()

    private var inFlight = 0
    private val mainHandler = Handler(Looper.getMainLooper())
    private var idleRunnable: Runnable? = null

    fun isInstalled(): Boolean = try {
        ctx.packageManager.getPackageInfo(getTargetPackageName(), 0)
        true
    } catch (_: PackageManager.NameNotFoundException) {
        false
    }

    fun ensureBoundAsync(
        onReady: (ISmartconnectService) -> Unit,
        onError: (PluginResponse.Error) -> Unit
    ) {
        val currentService = service

        if (currentService != null) {
            touch()
            onReady(currentService)
            return
        }

        if (isBinding) {
            pendingCallbacks.add(onReady)
            return
        }

        isBinding = true
        pendingCallbacks.add(onReady)

        val intent = Intent().apply {
            component = ComponentName(getTargetPackageName(), serviceClassName)
        }

        val conn = object : ServiceConnection {
            override fun onServiceConnected(name: ComponentName?, binder: IBinder?) {
                val svc = ISmartconnectService.Stub.asInterface(binder)
                service = svc
                connection = this
                isBinding = false

                touch()

                val callbacks = ArrayList(pendingCallbacks)
                pendingCallbacks.clear()
                callbacks.forEach { it(svc) }
            }

            override fun onServiceDisconnected(name: ComponentName?) {
                handleDisconnect("Service disconnected")
            }

            override fun onBindingDied(name: ComponentName?) {
                handleDisconnect("Binding died")
            }
        }

        try {
            val binded = ctx.bindService(
                intent,
                conn,
                Context.BIND_AUTO_CREATE or Context.BIND_ALLOW_ACTIVITY_STARTS
            )

            if (!binded) {
                isBinding = false
                pendingCallbacks.clear()
                onError(PluginResponse.Error("serviceBindFailed", "Unable to bind to GP tom service"))
            }
        } catch (e: Exception) {
            isBinding = false
            pendingCallbacks.clear()
            onError(PluginResponse.Error("serviceException", "Bind exception: ${e.message}"))
        }
    }

    private fun handleDisconnect(reason: String) {
        service = null
        connection = null
        isBinding = false
        pendingCallbacks.clear()
        onDisconnected(reason)
    }

    fun markInFlightStart() {
        inFlight += 1
        cancelIdle()
    }

    fun markInFlightEnd() {
        if (inFlight > 0) inFlight -= 1
        scheduleIdleDisconnect()
    }

    fun touch() {
        cancelIdle()
        scheduleIdleDisconnect()
    }

    fun unbindNow() {
        cancelIdle()
        val conn = connection ?: return
        try {
            ctx.unbindService(conn)
        } catch (_: Exception) {}
        connection = null
        service = null
        isBinding = false
        pendingCallbacks.clear()
    }

    private fun getTargetPackageName(): String = if (isDevProvider()) packageNameDev else packageNameProd

    private fun scheduleIdleDisconnect() {
        if (inFlight != 0) return
        val ms = idleDisconnectMsProvider()
        if (ms <= 0) return

        cancelIdle()
        val r = Runnable {
            if (inFlight == 0) unbindNow()
        }
        idleRunnable = r
        mainHandler.postDelayed(r, ms)
    }

    private fun cancelIdle() {
        idleRunnable?.let { mainHandler.removeCallbacks(it) }
        idleRunnable = null
    }
}