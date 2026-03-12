public enum DeeplinkError: String, Equatable, CaseIterable, Codable, Sendable {
    case failed
    case networkError
    case invalidClientId
    case merchantInfoMissing
    case failedTapToPay
    case failedToCloseBatch
    case unsupportedTransactionOperationOrType
    case invalidAmount
    case cannotBeVoided

    /// Login
    case invalidCredentials
    case tidNotAssignedToThisUser
    case tidAlreadyOccupied
    case anotherTidUsedOnThisDevice
    case passwordChangeRequired
    case passwordPendingConfirmation
    case invalidCode
    case invalidUserName
    case terminalSetupFailed
}
