enum ResultCodes {
    static let ok = "ok"
    static let notInitialized = "notInitialized"
    static let notInstalled = "notInstalled"
    static let unsupportedOnPlatform = "unsupportedOnPlatform"
    static let invalidArgument = "invalidArgument"
    static let timeout = "timeout"
    static let serviceBindFailed = "serviceBindFailed"
    static let internalError = "internalError"
    static let failed = "failed"
    static let networkError = "networkError"
    static let invalidClientId = "invalidClientId"
    static let merchantInfoMissing = "merchantInfoMissing"
    static let failedTapToPay = "failedTapToPay"
    static let failedToCloseBatch = "failedToCloseBatch"
    static let invalidDeeplink = "invalidDeeplink"

    static func from(_ error: DeeplinkError?) -> String {
        guard let error else {
            return ResultCodes.failed
        }

        switch error {
        case .failed:
            return ResultCodes.failed

        case .networkError:
            return ResultCodes.networkError

        case .invalidClientId:
            return ResultCodes.invalidClientId

        case .merchantInfoMissing:
            return ResultCodes.merchantInfoMissing

        case .failedTapToPay:
            return ResultCodes.failedTapToPay

        case .failedToCloseBatch:
            return ResultCodes.failedToCloseBatch
        }
    }
}
