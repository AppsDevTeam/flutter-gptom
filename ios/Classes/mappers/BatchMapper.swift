import Foundation

struct BatchMapper {
    private init() {}
    
    static func toMap(_ batch: Batch) -> [String: Any] {
        var b = JsonMapBuilder()
        
        b.put(JsonKeys.amsId, batch.amsId)
        b.put(JsonKeys.batchNumber, batch.batchNumber)
        b.put(JsonKeys.communicationId, batch.communicationId)
        
        b.put(JsonKeys.currencyCode, batch.currency)
        
        b.put(JsonKeys.date, batch.date?.ISO8601Format())
        b.put(JsonKeys.firstTransactionDate, batch.firstTransactionDate?.ISO8601Format())
        b.put(JsonKeys.previousBatchDate, batch.previousBatchDate?.ISO8601Format())
        
        b.put(JsonKeys.saleAmount, batch.saleAmount?.int64)
        b.put(JsonKeys.saleCount, batch.saleCount)
        
        b.put(JsonKeys.totalAmount, batch.totalAmount?.int64)
        b.put(JsonKeys.totalCount, batch.totalCount)
        
        b.put(JsonKeys.voidAmount, batch.voidAmount?.int64)
        b.put(JsonKeys.voidCount, batch.voidCount)
        
        b.put(JsonKeys.invalidCount, batch.invalidCount)
        
        b.put(JsonKeys.tipAmount, batch.tipAmount?.int64)
        b.put(JsonKeys.tipCount, batch.tipCount)
        b.put(JsonKeys.tipAverage, batch.tipAverage?.int64)
        b.put(JsonKeys.tipAveragePercentage, batch.tipAveragePercentage)
        
        return b.build()
    }
}
