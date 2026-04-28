enum Kinds {
    static let appStatus = "appStatus"
    static let info = "info"
    static let state = "state"
    static let detail = "detail"
    static let sale = "sale"
    static let cancel = "cancel"
    static let refund = "refund"
    static let closeBatch = "closeBatch"
    static let login = "login"
    static let logout = "logout"
    static let changePassword = "changePassword"
    
    static func fromTransactionType(_ type: Int?) -> String? {
        switch type {
        case 1: return sale
        case 2: return cancel
        case 3: return refund
        case 4: return closeBatch
        default: return nil
        }
    }

    static func toTransactionType(_ kind: String) -> Int? {
        switch kind {
        case sale: return 1
        case cancel: return 2
        case refund: return 3
        case closeBatch: return 4
        default: return nil
        }
    }
}
