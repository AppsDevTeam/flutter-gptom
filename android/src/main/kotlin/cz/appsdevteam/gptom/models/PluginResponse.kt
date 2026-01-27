package cz.appsdevteam.gptom.models

import cz.appsdevteam.gptom.JsonKeys
import cz.appsdevteam.gptom.models.ResultCodes

sealed class PluginResponse {
    data class Success(val data: Any?) : PluginResponse()

    data class Error(val code: String, val message: String) : PluginResponse() {
        fun toEventData(): Map<String, Any?> = mapOf(
            JsonKeys.code to code,
            JsonKeys.message to message
        )
    }

    fun toMap(): Map<String, Any?> = when (this) {
        is Success -> mapOf(JsonKeys.code to ResultCodes.OK, JsonKeys.data to data)
        is Error -> mapOf(JsonKeys.code to code, JsonKeys.message to message, JsonKeys.data to null)
    }
}