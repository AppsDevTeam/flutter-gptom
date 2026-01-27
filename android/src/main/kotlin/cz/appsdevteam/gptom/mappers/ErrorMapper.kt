package cz.appsdevteam.gptom.mappers

import cn.nexgo.smartconnect.model.ErrorResultEntity
import cn.nexgo.smartconnect.model.ErrorResultV2Entity
import cn.nexgo.smartconnect.model.ErrorPlatform
import cz.appsdevteam.gptom.core.JsonKeys

object ErrorMapper {

    fun toMap(e: ErrorResultEntity): Map<String, Any?> = mapOf(
        JsonKeys.errorCode to e.errorCode,
        JsonKeys.supportId to e.supportID,
        JsonKeys.exception to e.exception,
    )

    fun toMap(e: ErrorResultV2Entity): Map<String, Any?> = mapOf(
        JsonKeys.platform to platformToString(e.platform),
        JsonKeys.code to e.code,
        JsonKeys.internalErrorCode to e.internalErrorCode,
        JsonKeys.internalErrorSubCode to e.internalErrorSubCode,
        JsonKeys.cause to e.cause?.let { toMap(it) },
    )

    private fun platformToString(p: ErrorPlatform?) = when (p) {
        ErrorPlatform.TOM_APP -> "tomApp"
        ErrorPlatform.AMS -> "ams"
        ErrorPlatform.EXTERNAL -> "external"
        null -> null
    }   
}