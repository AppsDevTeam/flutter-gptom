import Foundation

struct RegisterMapper {
    private init() {}

    static func toMap(
        transactionId: String,
        originReferenceNum: String?,
        clientId: String?
    ) -> [String: Any] {
        var b = JsonMapBuilder()

        b.put(JsonKeys.resultCode, 0)
        b.put(JsonKeys.transactionId, transactionId)
        b.put(JsonKeys.originReferenceNum, originReferenceNum)
        b.put(JsonKeys.clientId, clientId)
        b.put(JsonKeys.responseMessage, nil)
        b.put(JsonKeys.error, nil)

        return b.build()
    }
}
