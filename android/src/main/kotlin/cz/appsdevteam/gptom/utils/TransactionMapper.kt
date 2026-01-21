package cz.appsdevteam.gptom.mappers

import cn.nexgo.smartconnect.model.MerchantInfoEntity
import cn.nexgo.smartconnect.model.TransactionResultV2Entity
import cz.appsdevteam.gptom.mappers.MerchantInfoMapper
import cz.appsdevteam.gptom.JsonKeys

object TransactionResultMapper {

    fun toMap(e: TransactionResultV2Entity): Map<String, Any?> = mapOf(
        JsonKeys.result to e.result,
        JsonKeys.error to e.error?.let { ErrorMapper.toMap(it) },

        JsonKeys.clientId to e.clientID,
        JsonKeys.responseMessage to e.responseMessage,

        JsonKeys.transactionId to e.transactionID,
        JsonKeys.externalTransactionId to e.externalTransactionID,
        JsonKeys.transactionType to e.transactionType,

        JsonKeys.merchantId to e.merchantID,
        JsonKeys.terminalId to e.terminalID,

        JsonKeys.currencyCode to e.currencyCode,
        JsonKeys.amount to e.amount,
        JsonKeys.tipAmount to e.tipAmount,
        JsonKeys.cashbackAmount to e.cashbackAmount,

        JsonKeys.cardNumber to e.cardNumber,
        JsonKeys.cardIssuer to e.cardIssuer,
        JsonKeys.cardDataEntry to e.cardDataEntry,

        JsonKeys.approvedCode to e.approvedCode,
        JsonKeys.referenceNumber to e.referenceNumber,
        JsonKeys.invoiceNumber to e.invoiceNumber,

        JsonKeys.date to e.date,
        JsonKeys.time to e.time,

        JsonKeys.emvAid to e.emvAid,
        JsonKeys.emvAppLabel to e.emvAppLabel,

        JsonKeys.sequenceNumber to e.sequenceNumber,
        JsonKeys.batchNumber to e.batchNumber,

        JsonKeys.batchTotalNum to e.batchTotalNum,
        JsonKeys.batchTotalAmount to e.batchTotalAmount,
        JsonKeys.batchSaleNum to e.batchSaleNum,
        JsonKeys.batchSaleAmount to e.batchSaleAmount,
        JsonKeys.batchVoidNum to e.batchVoidNum,
        JsonKeys.batchVoidAmount to e.batchVoidAmount,

        JsonKeys.printByPaymentApp to e.printByPaymentApp,
        JsonKeys.cardProduct to e.cardProduct?.name,
        JsonKeys.receiptNumber to e.receiptNumber,
        JsonKeys.pinOk to e.isPinOk, 
        JsonKeys.merchantInfo to e.merchantInfo?.let { MerchantInfoMapper.toMap(it) },
        JsonKeys.cardHolderVerificationMethod to e.cardHolderVerificationMethod?.name,

        JsonKeys.blikCode to e.blikCode,
    )
}

