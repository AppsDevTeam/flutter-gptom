package cz.appsdevteam.gptom.mappers

import cn.nexgo.smartconnect.model.MerchantInfoEntity
import cz.appsdevteam.gptom.JsonKeys

object MerchantInfoMapper {

    fun toMap(e: MerchantInfoEntity): Map<String, Any?> = mapOf(
        JsonKeys.company to e.company,
        JsonKeys.city to e.city,
        JsonKeys.street to e.street,
        JsonKeys.house to e.house,
        JsonKeys.location to e.location,
        JsonKeys.country to e.country,
        JsonKeys.zip to e.zip,
    )
}