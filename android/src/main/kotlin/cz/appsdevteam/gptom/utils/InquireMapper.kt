package cz.appsdevteam.gptom.mappers

import cn.nexgo.smartconnect.model.InquireResultEntity
import cn.nexgo.smartconnect.model.MerchantInfoEntity
import cz.appsdevteam.gptom.mappers.MerchantInfoMapper
import cz.appsdevteam.gptom.utils.DateUtils
import cz.appsdevteam.gptom.JsonKeys

object InquireResultMapper {

    fun toMap(e: InquireResultEntity): Map<String, Any?> = mapOf(
        JsonKeys.result to e.result,
        JsonKeys.responseMessage to e.responseMessage,

        JsonKeys.transactionId to e.trasanctionID,
        JsonKeys.externalTransactionId to e.externalTransactionID,

        JsonKeys.transactionType to e.transacitonType,

        JsonKeys.merchantId to e.merchantID,
        JsonKeys.terminalId to e.terminalID,

        JsonKeys.currencyCode to e.currencyCode,
        JsonKeys.amount to e.amount,
        JsonKeys.tipAmount to e.tipAmount,
        JsonKeys.cashbackAmount to e.cashbackAmount,

        JsonKeys.cardProduct to e.cardProduct?.name,
        JsonKeys.cardNumber to e.cardNumber,
        JsonKeys.cardIssuer to e.cardIssuer,
        JsonKeys.cardDataEntry to e.cardDataEntry,

        JsonKeys.approvedCode to e.approvedCode,
        JsonKeys.referenceNumber to e.referenceNumber,
        JsonKeys.traceNumber to e.traceNumber,
        JsonKeys.invoiceNumber to e.invoiceNumber,

        JsonKeys.date to DateUtils.toISO8601(e.date, e.time),

        JsonKeys.emvAid to e.emvAid,
        JsonKeys.emvAppLabel to e.emvAppLable,

        JsonKeys.sequenceNumber to e.sequenceNumber,
        JsonKeys.batchNumber to e.batchNumber,

        JsonKeys.receiptNumber to e.receiptNumber,
        JsonKeys.pinOk to e.isPinOk,
        JsonKeys.merchantInfo to e.merchantInfo?.let { MerchantInfoMapper.toMap(it) },
        JsonKeys.cardHolderVerificationMethod to e.cardHolderVerificationMethod?.name,
        JsonKeys.blikCode to e.blikCode,
    )
}