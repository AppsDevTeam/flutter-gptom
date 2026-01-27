package cz.appsdevteam.gptom.mappers

import cn.nexgo.smartconnect.model.RegisterResultV2Entity
import cz.appsdevteam.gptom.mappers.ErrorMapper
import cz.appsdevteam.gptom.core.JsonKeys

object RegisterResultMapper {
  fun toMap(e: RegisterResultV2Entity, originRef: String?): Map<String, Any?> = mapOf(
    JsonKeys.resultCode to e.resultCode,
    JsonKeys.transactionId to e.transactionId,
    JsonKeys.clientId to e.clientID,
    JsonKeys.responseMessage to e.responseMessage,
    JsonKeys.error to (e.error?.let { ErrorMapper.toMap(it) }),
    JsonKeys.originReferenceNum to originRef,
  )
}