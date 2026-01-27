import Foundation

struct TransactionMapper {
    private init() {}

    static func toMap(_ tx: TransactionData) -> [String: Any] {
        var b = JsonMapBuilder()

        b.put(JsonKeys.transactionId, tx.transactionID)
        b.put(JsonKeys.amsId, tx.amsID)

        b.put(JsonKeys.result, tx.result)

        b.put(JsonKeys.merchantId, tx.merchantID)
        b.put(JsonKeys.terminalId, tx.terminalID)

        b.put(JsonKeys.currencyCode, tx.currencyCode.map { JsonUtils.asNumericCurrencyCode($0) })
        b.put(JsonKeys.amount, tx.amount.flatMap { $0.amount?.int64 })
        b.put(JsonKeys.tipAmount, tx.tipAmount.flatMap { $0.amount?.int64 })
        b.put(JsonKeys.batchTotalAmount, tx.totalAmount.flatMap { $0.amount?.int64 })

        b.put(JsonKeys.cardNumber, tx.cardNumber)
        b.put(JsonKeys.cardProduct, tx.cardType?.rawValue)
        b.put(JsonKeys.cardDataEntry, tx.cardEntryMode)

        b.put(JsonKeys.approvedCode, tx.authorizationCode)
        b.put(JsonKeys.referenceNumber, tx.referenceNumber)

        b.put(JsonKeys.date, tx.date?.ISO8601Format())

        b.put(JsonKeys.emvAid, tx.emvAid)
        b.put(JsonKeys.emvAppLabel, tx.emvAppLabel)

        b.put(JsonKeys.batchNumber, tx.batchNumber)
        b.put(JsonKeys.sequenceNumber, tx.sequenceNumber)

        b.put(JsonKeys.receiptNumber, tx.receiptNumber)

        b.put(JsonKeys.pinOk, tx.pinOk)
        b.put(JsonKeys.blikCode, tx.blikCode)

        return b.build()
    }
}
