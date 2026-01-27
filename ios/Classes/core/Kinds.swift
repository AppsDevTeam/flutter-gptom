enum Kinds {
    static let appStatus = "appStatus"
    static let info = "info"
    static let state = "state"
    static let detail = "detail"
    static let sale = "sale"
    static let cancel = "cancel"
    static let refund = "refund"
    static let closeBatch = "closeBatch"
    
    static func fromTransactionType(_ type: Int?) -> String? {
        switch type {
        case 1: return sale
        case 2: return cancel
        case 3: return refund
        case 4: return closeBatch
        default: return nil
        }
    }
}
