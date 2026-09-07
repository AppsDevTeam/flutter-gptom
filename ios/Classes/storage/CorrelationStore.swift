import Foundation

/// Remembers the `requestID` the plugin sent to GP tom for an in-flight
/// deeplink operation, so the result event can be correlated back to the ID the
/// Flutter caller passed in.
///
/// Separate from [PendingStore] on purpose:
/// - `PendingStore` is the client-visible crash-recovery record and is written
///   only when the caller asks for it (`persistPending: true`).
/// - `CorrelationStore` is the plugin's own bookkeeping and is always written,
///   so `GpTomResult.transactionId` carries the caller's ID for every
///   operation, including `closeBatch` (which registers without persisting).
///
/// Backed by `UserDefaults` because iOS may terminate the app while GP tom is
/// in the foreground; the correlation must survive until the return deeplink
/// arrives. One entry per kind is enough — the app cannot start a second
/// operation of the same kind while it is in the background.
final class CorrelationStore {
    private static let keyPrefix = "correlation_requestId_"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(kind: String, transactionId: String) {
        defaults.set(transactionId, forKey: Self.key(kind))
    }

    func read(kind: String) -> String? {
        defaults.string(forKey: Self.key(kind))
    }

    func clear(kind: String) {
        defaults.removeObject(forKey: Self.key(kind))
    }

    private static func key(_ kind: String) -> String {
        keyPrefix + kind
    }
}
