package cz.appsdevteam.gptom.mappers

import cn.nexgo.smartconnect.model.UserAddress
import cz.appsdevteam.gptom.JsonKeys

object UserAddressMapper {

    fun toMap(e: UserAddress): Map<String, Any?> = mapOf(
        JsonKeys.city to e.city,
        JsonKeys.street to e.street,
        JsonKeys.house to e.house,
        JsonKeys.location to e.location,
        JsonKeys.country to e.country,
        JsonKeys.zip to e.zip,
    )
}

