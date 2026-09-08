package cz.appsdevteam.gptom.support

import android.os.Handler
import android.os.Looper
import android.util.Log
import cz.appsdevteam.gptom.core.JsonKeys

object GpTomLog {
    /** Lines kept while no Dart listener is attached; the oldest are dropped. */
    private const val BUFFER_LIMIT = 200

    private const val LEVEL_DEBUG = "debug"
    private const val LEVEL_INFO = "info"
    private const val LEVEL_WARNING = "warning"
    private const val LEVEL_ERROR = "error"

    private val mainHandler = Handler(Looper.getMainLooper())
    private val buffer = ArrayDeque<Map<String, Any?>>()

    private var enabled: Boolean = false
    private var tag: String = "ADT_GP_TOM"
    private var sink: ((Map<String, Any?>) -> Unit)? = null

    fun configure(
        enabled: Boolean,
        tag: String = this.tag,
    ) {
        this.enabled = enabled
        this.tag = tag
    }

    /**
     * Starts mirroring log lines to Dart.
     *
     * Whatever was buffered since the last detach is flushed first: the plugin
     * already logs from init(), which runs before Dart can subscribe, and those
     * are exactly the lines worth having.
     */
    fun attachSink(newSink: (Map<String, Any?>) -> Unit) {
        val pending: List<Map<String, Any?>>

        synchronized(buffer) {
            sink = newSink
            pending = buffer.toList()
            buffer.clear()
        }

        pending.forEach { entry -> mainHandler.post { newSink(entry) } }
    }

    fun detachSink() {
        synchronized(buffer) {
            sink = null
        }
    }

    fun d(msg: String, data: Any? = null,) {
        if (!enabled) return
        Log.d(tag, format(msg, data))
        emit(LEVEL_DEBUG, msg, data)
    }

    fun i(msg: String, data: Any? = null,) {
        if (!enabled) return
        Log.i(tag, format(msg, data))
        emit(LEVEL_INFO, msg, data)
    }

    fun w(msg: String, data: Any? = null,) {
        if (!enabled) return
        Log.w(tag, format(msg, data))
        emit(LEVEL_WARNING, msg, data)
    }

    fun e(msg: String, tr: Throwable? = null,) {
        if (!enabled) return
        if (tr != null) Log.e(tag, msg, tr) else Log.e(tag, msg)
        emit(LEVEL_ERROR, msg, tr)
    }

    private fun emit(level: String, msg: String, data: Any?) {
        val entry = mapOf(
            JsonKeys.level to level,
            JsonKeys.message to msg,
            JsonKeys.data to data?.toString(),
            JsonKeys.createdAtMs to System.currentTimeMillis(),
        )

        // Buffering and handing the entry over happen under the same lock, so a
        // listener attaching right now either flushes this entry or receives it
        // directly - it cannot fall between the two.
        val currentSink = synchronized(buffer) {
            val current = sink

            if (current == null) {
                if (buffer.size >= BUFFER_LIMIT) buffer.removeFirst()
                buffer.addLast(entry)
            }

            current
        }

        if (currentSink != null) {
            // EventSink.success must be called on the main thread; the binder
            // callbacks this logs from run on their own threads.
            mainHandler.post { currentSink(entry) }
        }
    }

    private fun format(msg: String, data: Any?): String {
        return if (data == null) msg else "$msg | data=$data"
    }
}
