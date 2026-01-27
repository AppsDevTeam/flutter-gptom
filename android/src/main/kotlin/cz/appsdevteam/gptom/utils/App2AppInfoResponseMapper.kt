package cz.appsdevteam.gptom.mappers

import cn.nexgo.smartconnect.model.App2AppInfoResponse
import cz.appsdevteam.gptom.mappers.UserAddressMapper
import cz.appsdevteam.gptom.JsonKeys

object App2AppInfoResponseMapper {

    fun toMap(e: App2AppInfoResponse): Map<String, Any?> = mapOf(
        JsonKeys.appVersion to e.appVersion,
        JsonKeys.isLoggedIn to e.isLoggedIn,
        JsonKeys.tid to e.tid,
        JsonKeys.mid to e.mid,
        JsonKeys.clientId to e.clientId,
        JsonKeys.businessId to e.businessId,
        JsonKeys.email to e.email,
        JsonKeys.vat to e.vat,
        JsonKeys.tipEnabled to e.tipEnabled,
        JsonKeys.printerAvailable to e.printerAvailable,
        JsonKeys.manualTransactionRestricted to e.manualTransactionRestricted,
        JsonKeys.merchantLocationEntity to
        e.merchantLocationEntity?.let { UserAddressMapper.toMap(it) }
    )
}

