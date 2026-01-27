import Foundation

final class PendingStore {
    private let defaults: UserDefaults
    private let keyTx = "pending_transactionId"
    private let keyRef = "pending_originReferenceNum"
    private let keyCreated = "pending_createdAtMs"
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func save(transactionId: String, originReferenceNum: String?, createdAtMs: Int64) {
        defaults.set(transactionId, forKey: keyTx)
        if let ref = originReferenceNum {
            defaults.set(ref, forKey: keyRef)
        } else {
            defaults.removeObject(forKey: keyRef)
        }
        defaults.set(NSNumber(value: createdAtMs), forKey: keyCreated)
    }
    
    func read() -> [String: Any?]? {
        guard let tx = defaults.string(forKey: keyTx) else { return nil }
        let ref = defaults.string(forKey: keyRef)
        let createdNumber = defaults.object(forKey: keyCreated) as? NSNumber
        let created: Int64? = createdNumber?.int64Value
        return [
            JsonKeys.transactionId: tx,
            JsonKeys.originReferenceNum: ref,
            JsonKeys.createdAtMs: created,
        ]
    }
    
    func clear() {
        defaults.removeObject(forKey: keyTx)
        defaults.removeObject(forKey: keyRef)
        defaults.removeObject(forKey: keyCreated)
    }
}
