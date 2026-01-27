package cz.appsdevteam.gptom.mappers

import cn.nexgo.smartconnect.model.TransactionResultV2Entity
import cz.appsdevteam.gptom.support.DateUtils
import cz.appsdevteam.gptom.core.JsonKeys

object BatchMapper {

    fun toMap(e: TransactionResultV2Entity): Map<String, Any?> = mapOf(
        JsonKeys.transactionId to e.transactionID,
        
        JsonKeys.batchNumber to e.batchNumber,
        JsonKeys.currencyCode to e.currencyCode?.toString(),

        JsonKeys.date to DateUtils.toISO8601(e.date, e.time),

        JsonKeys.totalCount to e.batchTotalNum,
        JsonKeys.totalAmount to e.batchTotalAmount,
        JsonKeys.saleCount to e.batchSaleNum,
        JsonKeys.saleAmount to e.batchSaleAmount,
        JsonKeys.voidCount to e.batchVoidNum,
        JsonKeys.voidAmount to e.batchVoidAmount,
        
        JsonKeys.tipAmount to e.tipAmount,
    )
}

