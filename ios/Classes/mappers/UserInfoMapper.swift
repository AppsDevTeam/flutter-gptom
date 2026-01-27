import Foundation

struct UserInfoMapper {
    private init() {}
    
    static func toMap(_ userInfo: UserInfo) -> [String: Any] {
        var b = JsonMapBuilder()
        
        b.put(JsonKeys.clientId, userInfo.clientId)
        b.put(JsonKeys.email, userInfo.email)
        b.put(JsonKeys.businessId, userInfo.businessId)
        b.put(JsonKeys.vat, userInfo.vatId)
        b.put(JsonKeys.tid, userInfo.tid)
        b.put(JsonKeys.mid, userInfo.mid)
        b.put(JsonKeys.tipEnabled, userInfo.tipEnabled)
        b.put(JsonKeys.printerAvailable, userInfo.printerAvailable)
        b.put(JsonKeys.manualTransactionRestricted, userInfo.manualTransactionRestricted)
        
        b.put(
            JsonKeys.merchantLocationEntity,
            AddressMapper.toMap(userInfo.merchantLocation)
        )
        
        return b.build()
    }
}
