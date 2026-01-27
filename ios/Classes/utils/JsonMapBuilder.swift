import Foundation

struct JsonMapBuilder {
    private var map: [String: Any] = [:]

    mutating func put(_ key: String, _ value: Any?) {
        map[key] = value ?? NSNull()
    }

    mutating func putAll(_ other: [String: Any]) {
        for (k, v) in other {
            map[k] = v
        }
    }

    mutating func putIfNotNil(_ key: String, _ value: Any?) {
        if let v = value { map[key] = v }
    }

    mutating func putMap(_ key: String, _ value: [String: Any]?) {
        map[key] = value ?? NSNull()
    }

    func build() -> [String: Any] { map }
}
