import Foundation

struct JsonUtils {
    private init() {}

    static func asString(_ value: Any?) -> String? {
        guard let value = value else { return nil }
        if let string = value as? String {
            return string
        }
        return String(describing: value)
    }

    static func asInt(_ value: Any?) -> Int? {
        guard let value = value else { return nil }
        if let int = value as? Int {
            return int
        }
        if let number = value as? NSNumber {
            return number.intValue
        }
        if let string = value as? String {
            return Int(string)
        }
        return nil
    }

    static func asRequiredInt(_ value: Any?, fallback: Int = 0) -> Int {
        return asInt(value) ?? fallback
    }

    static func asBool(_ value: Any?) -> Bool? {
        guard let value = value else { return nil }
        if let bool = value as? Bool {
            return bool
        }
        if let string = value as? String {
            let lowercased = string.lowercased()
            if lowercased == "true" { return true }
            if lowercased == "false" { return false }
        }
        if let number = value as? NSNumber {
            if number == NSNumber(value: 1) { return true }
            if number == NSNumber(value: 0) { return false }
        }
        return nil
    }

    static func asDateTime(_ value: Any?) -> Date? {
        guard let value = value else { return nil }
        if let date = value as? Date {
            return date
        }
        if let string = value as? String {
            let formatter = ISO8601DateFormatter()
            return formatter.date(from: string)
        }
        if let timestamp = value as? NSNumber {
            return Date(timeIntervalSince1970: TimeInterval(timestamp.doubleValue / 1000))
        }
        if let timestamp = value as? Int {
            return Date(timeIntervalSince1970: TimeInterval(timestamp / 1000))
        }
        return nil
    }

    static func asMap(_ value: Any?) -> [String: Any]? {
        guard let value = value else { return nil }
        if let dict = value as? [String: Any] {
            return dict
        }
        return nil
    }

    static func asArray(_ value: Any?) -> [Any]? {
        guard let value = value else { return nil }
        if let array = value as? [Any] {
            return array
        }
        return nil
    }

    static func asNumericCurrencyCode(_ code: String?) -> String? {
        guard let code = code else { return nil }
        if let currency = Currency.from(code: code) {
            return currency.rawValue
        }
        return code
    }
}
