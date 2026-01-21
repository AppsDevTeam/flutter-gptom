package cz.appsdevteam.gptom

import android.util.Log

object GpTomLog {
    private var enabled: Boolean = false
    private var tag: String = "ADT_GP_TOM"

    fun configure(
        enabled: Boolean,
        tag: String = this.tag,
    ) {
        this.enabled = enabled
        this.tag = tag
    }

    fun d(msg: String, data: Any? = null,) {
        if (!enabled) return
        Log.d(tag, format(msg, data))
    }

    fun i(msg: String, data: Any? = null,) {
        if (!enabled) return
        Log.i(tag, format(msg, data))
    }

    fun w(msg: String, data: Any? = null,) {
        if (!enabled) return
        Log.w(tag, format(msg, data))
    }

    fun e(msg: String, tr: Throwable? = null,) {
        if (!enabled) return
        if (tr != null) Log.e(tag, msg, tr) else Log.e(tag, msg)
    }

    private fun format(msg: String, data: Any?): String {
        return if (data == null) msg else "$msg | data=$data"
    }
}