package cz.appsdevteam.gptom.storage

import android.content.Context
import androidx.core.content.edit
import cz.appsdevteam.gptom.core.JsonKeys

class PendingStore(ctx: Context) {
    private val prefs = ctx.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun save(transactionId: String, originReferenceNum: String?, amsId: String?) {
        val now = System.currentTimeMillis()

        prefs.edit {
            putString(KEY_TX, transactionId)
            if (originReferenceNum != null) putString(KEY_REF, originReferenceNum) else remove(KEY_REF)
            putLong(KEY_CREATED_AT, now)
            if (amsId != null) putString(KEY_AMS, amsId) else remove(KEY_AMS)
        }
    }

    fun read(): Map<String, Any?>? {
        val tx = prefs.getString(KEY_TX, null) ?: return null
        val ref = prefs.getString(KEY_REF, null) ?: return null
        val createdAtMs = prefs.getLong(KEY_CREATED_AT, 0L)
        val ams = prefs.getString(KEY_AMS, null)

        return buildMap<String, Any?> {
            put(JsonKeys.transactionId, tx)
            put(JsonKeys.originReferenceNum, ref)
            put(JsonKeys.createdAtMs, createdAtMs)
            if (ams != null) put(JsonKeys.amsId, ams)
        }
    }

    fun clear() {
        prefs.edit {
            remove(KEY_TX)
            remove(KEY_REF)
            remove(KEY_AMS)
            remove(KEY_CREATED_AT)
        }
    }

    companion object {
        private const val PREFS_NAME = "adt_gptom"

        private const val KEY_TX = "pending_transactionId"
        private const val KEY_REF = "pending_originReferenceNum"
        private const val KEY_AMS = "pending_amsId"
        private const val KEY_CREATED_AT = "pending_createdAtMs"
    }
}