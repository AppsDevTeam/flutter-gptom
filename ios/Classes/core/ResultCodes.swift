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
    static let unsupportedTransactionOperationOrType = "unsupportedTransactionOperationOrType"
    static let invalidAmount = "invalidAmount"
    static let cannotBeVoided = "cannotBeVoided"
    static let invalidCredentials = "invalidCredentials"
    static let tidNotAssignedToThisUser = "tidNotAssignedToThisUser"
    static let tidAlreadyOccupied = "tidAlreadyOccupied"
    static let anotherTidUsedOnThisDevice = "anotherTidUsedOnThisDevice"
    static let passwordChangeRequired = "passwordChangeRequired"
    static let passwordPendingConfirmation = "passwordPendingConfirmation"
    static let invalidCode = "invalidCode"
    static let invalidUserName = "invalidUserName"
    static let terminalSetupFailed = "terminalSetupFailed"
    static let cancelled = "cancelled"

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
        case .unsupportedTransactionOperationOrType:
            return ResultCodes.unsupportedTransactionOperationOrType
        case .invalidAmount:
            return ResultCodes.invalidAmount
        case .cannotBeVoided:
            return ResultCodes.cannotBeVoided
        case .invalidCredentials:
            return ResultCodes.invalidCredentials
        case .tidNotAssignedToThisUser:
            return ResultCodes.tidNotAssignedToThisUser
        case .tidAlreadyOccupied:
            return ResultCodes.tidAlreadyOccupied
        case .anotherTidUsedOnThisDevice:
            return ResultCodes.anotherTidUsedOnThisDevice
        case .passwordChangeRequired:
            return ResultCodes.passwordChangeRequired
        case .passwordPendingConfirmation:
            return ResultCodes.passwordPendingConfirmation
        case .invalidCode:
            return ResultCodes.invalidCode
        case .invalidUserName:
            return ResultCodes.invalidUserName
        case .terminalSetupFailed:
            return ResultCodes.terminalSetupFailed
        }
    }
}
