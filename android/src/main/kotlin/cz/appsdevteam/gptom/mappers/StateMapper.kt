package cz.appsdevteam.gptom.mappers

import cn.nexgo.smartconnect.model.StateResultEntity
import cz.appsdevteam.gptom.mappers.ErrorMapper
import cz.appsdevteam.gptom.core.JsonKeys

object StateResultMapper {

    fun toMap(e: StateResultEntity): Map<String, Any?> = mapOf(
        JsonKeys.resultCode to e.resultCode,
        JsonKeys.transactionId to e.transactionId,
        JsonKeys.state to e.state,
        JsonKeys.isRepeatable to e.repeatable,
        JsonKeys.created to e.created?.time,
        JsonKeys.updated to e.updated?.time,
        JsonKeys.error to e.error?.let { ErrorMapper.toMap(it) },
    )
}