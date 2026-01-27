enum DeeplinkPath {
  case createTransaction
  case cancelTransaction
  case refundTransaction
  case transactionDetail
  case closeBatch
  case login
  case result

  var path: String {
    switch self {
    case .createTransaction: return "transaction/create"
    case .cancelTransaction: return "transaction/cancel"
    case .refundTransaction: return "transaction/refund"
    case .transactionDetail: return "transaction/detail"
    case .closeBatch: return "batch/close"
    case .login: return "login"
    case .result: return "result"
    }
  }
}