import Foundation

struct AddressMapper {
    private init() {}

    static func toMap(_ address: Address) -> [String: Any] {
        var b = JsonMapBuilder()

        b.put(JsonKeys.city, address.city)
        b.put(JsonKeys.county, address.county)
        b.put(JsonKeys.house, address.house)
        b.put(JsonKeys.location, address.location)
        b.put(JsonKeys.street, address.street)
        b.put(JsonKeys.zip, address.zip)

        return b.build()
    }
}
