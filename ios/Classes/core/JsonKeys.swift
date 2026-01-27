import Foundation

public struct JsonKeys {
    private init() {}
    
    public static let appVersion = "appVersion"
    public static let isLoggedIn = "isLoggedIn"
    public static let tid = "tid"
    public static let mid = "mid"
    public static let businessId = "businessId"
    public static let email = "email"
    public static let vat = "vat"
    public static let tipEnabled = "tipEnabled"
    public static let printerAvailable = "printerAvailable"
    public static let manualTransactionRestricted = "manualTransactionRestricted"
    public static let merchantLocationEntity = "merchantLocationEntity"
    
    public static let isDevelopment = "isDevelopment"
    public static let iosRedirectUrl = "iosRedirectUrl"
    public static let debugLogs = "debugLogs"
    
    public static let kind = "kind"
    public static let ok = "ok"
    public static let code = "code"
    public static let message = "message"
    public static let data = "data"
    public static let transactionId = "transactionId"
    public static let originReferenceNum = "originReferenceNum"
    public static let amsId = "amsId"
    
    public static let createdAtMs = "createdAtMs"
    
    public static let resultCode = "resultCode"
    public static let responseMessage = "responseMessage"
    public static let state = "state"
    public static let isRepeatable = "isRepeatable"
    public static let created = "created"
    public static let updated = "updated"
    
    public static let platform = "platform"
    public static let internalErrorCode = "internalErrorCode"
    public static let internalErrorSubCode = "internalErrorSubCode"
    public static let cause = "cause"
    
    public static let result = "result"
    public static let clientId = "clientId"
    
    public static let paymentMethod = "paymentMethod"
    public static let printByPaymentApp = "printByPaymentApp"
    public static let amount = "amount"
    public static let tipAmount = "tipAmount"
    public static let transactionType = "transactionType"
    public static let originTransactionId = "originTransactionId"
    public static let cancelMode = "cancelMode"
    public static let currencyCode = "currencyCode"
    public static let tipCollect = "tipCollect"
    
    public static let externalTransactionId = "externalTransactionId"
    
    public static let merchantId = "merchantId"
    public static let terminalId = "terminalId"
    
    public static let cashbackAmount = "cashbackAmount"
    
    public static let cardNumber = "cardNumber"
    public static let cardIssuer = "cardIssuer"
    public static let cardDataEntry = "cardDataEntry"
    
    public static let approvedCode = "approvedCode"
    public static let referenceNumber = "referenceNumber"
    public static let traceNumber = "traceNumber"
    public static let invoiceNumber = "invoiceNumber"
    
    public static let date = "date"
    
    public static let emvAid = "emvAid"
    public static let emvAppLable = "emvAppLable"
    
    public static let sequenceNumber = "sequenceNumber"
    public static let batchNumber = "batchNumber"
    
    public static let totalDebitNum = "totalDebitNum"
    public static let totalDebitAmount = "totalDebitAmount"
    public static let totalCreditNum = "totalCreditNum"
    public static let totalCreditAmount = "totalCreditAmount"
    
    public static let receiptNumber = "receiptNumber"
    public static let pinOk = "pinOk"
    public static let blikCode = "blikCode"
    
    public static let cardProduct = "cardProduct"
    
    public static let error = "error"
    public static let emvAppLabel = "emvAppLabel"
    
    public static let batchTotalNum = "batchTotalNum"
    public static let batchTotalAmount = "batchTotalAmount"
    public static let batchSaleNum = "batchSaleNum"
    public static let batchSaleAmount = "batchSaleAmount"
    public static let batchVoidNum = "batchVoidNum"
    public static let batchVoidAmount = "batchVoidAmount"
    
    public static let totalCount = "totalCount"
    public static let totalAmount = "totalAmount"
    public static let saleCount = "saleCount"
    public static let saleAmount = "saleAmount"
    public static let voidCount = "voidCount"
    public static let voidAmount = "voidAmount"
    
    public static let merchantInfo = "merchantInfo"
    public static let cardHolderVerificationMethod = "cardHolderVerificationMethod"
    
    public static let company = "company"
    public static let city = "city"
    public static let street = "street"
    public static let house = "house"
    public static let location = "location"
    public static let country = "country"
    public static let zip = "zip"
    
    public static let errorCode = "errorCode"
    public static let supportId = "supportId"
    public static let exception = "exception"
    
    public static let persistPending = "persistPending"
    
    public static let communicationId = "communicationId"
    public static let invalidCount = "invalidCount"
    public static let firstTransactionDate = "firstTransactionDate"
    public static let previousBatchDate = "previousBatchDate"
    public static let tipCount = "tipCount"
    public static let tipAverage = "tipAverage"
    public static let tipAveragePercentage = "tipAveragePercentage"
}
