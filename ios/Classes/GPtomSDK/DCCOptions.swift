import Foundation

public struct DCCOptions: Codable, Equatable, Sendable {
    public let amount: String
    public let currencyCode: String
    public let effectiveRate: Decimal
    public let markUpRate: String
    public let regionSchemaIndicator: String
    public let txnId: String?
    public let isDecline: Bool?

    func copy(txnId: String, isDecline: Bool) -> DCCOptions {
        .init(amount: amount,
              currencyCode: currencyCode,
              effectiveRate: effectiveRate,
              markUpRate: markUpRate,
              regionSchemaIndicator: regionSchemaIndicator,
              txnId: txnId,
              isDecline: isDecline)
    }
}

public struct DCCOptionsWrapper: Codable, Equatable, Sendable {
    public let original: DCCOptions?

    public let currencyCode: Currency
    public let amount: Amount

    // 3.20
    public let markUpRate: String

    /// A code indicating the card region and scheme (network) classification.
    ///
    /// The precise mapping is acquirer‑specific; typical values may differentiate EU vs non‑EU
    /// and Visa vs Mastercard, among others.
    ///
    /// - Examples: `"0"`, `"1"`, `"2"`, `"3"`.
    public let regionSchemaIndicator: Int

    /// The effective daily foreign exchange rate used to compute the DCC amount.
    ///
    /// This is typically the acquirer-provided FX rate for the quote window and may
    /// already include markup depending on the provider. Values are represented as a
    /// decimal number (e.g., units of DCC currency per unit of card currency, or vice versa).
    /// Refer to your provider's documentation for the exact convention.
    ///
    /// - Example: `26.7471`.
    public let exchangeRate: String

    private enum CodingKeys: String, CodingKey {
        case currencyCode
        case amount
        case markUpRate
        case regionSchemaIndicator
        case exchangeRate
    }

    public init(original: DCCOptions) throws {
        let currency = original.currencyCode.trimmingCharacters(in: .whitespacesAndNewlines)

        // If it's a 3-letter ISO code, attempt to construct Currency from ISO
        if currency.count == 3, let isoCurrency = Currency.from(code: currency.uppercased()) {
            self.currencyCode = isoCurrency
        } else {
            // Otherwise treat as numeric code possibly left-padded with zeros
            let normalizedNumeric: String
            if currency.hasPrefix("0") {
                normalizedNumeric = String(currency.dropFirst())
            } else {
                normalizedNumeric = currency
            }
            guard let numericCurrency = Currency(rawValue: normalizedNumeric) else {
                throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.currencyCode],
                                                        debugDescription: "Unsupported currency code: \(currency)"))
            }

            self.currencyCode = numericCurrency
        }

        guard let amountValue = Decimal(string: original.amount) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.amount],
                                                    debugDescription: "Failed parsing amount: \(original.amount)"))
        }

        self.amount = amountValue / 100

        self.markUpRate = DCCOptionsWrapper.parseMarkup(original.markUpRate)

        guard let regionSchemaIndicator = Int(original.regionSchemaIndicator) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.regionSchemaIndicator],
                                                    debugDescription: "Failed parsing regionSchemaIndicator: \(original.regionSchemaIndicator)"))
        }

        self.regionSchemaIndicator = regionSchemaIndicator

        self.exchangeRate = original.effectiveRate.description
        self.original = original
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let currencyCode = try container.decode(String.self, forKey: .currencyCode)
        self.currencyCode = Currency.from(code: currencyCode) ?? .EUR

        self.amount = try container.decode(Decimal.self, forKey: .amount)
        self.markUpRate = try container.decode(String.self, forKey: .markUpRate)
        self.regionSchemaIndicator = try container.decode(Int.self, forKey: .regionSchemaIndicator)
        self.exchangeRate = try container.decode(String.self, forKey: .exchangeRate)
        self.original = nil
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currencyCode.isoCode, forKey: .currencyCode)
        try container.encode(amount, forKey: .amount)
        try container.encode(markUpRate, forKey: .markUpRate)
        try container.encode(regionSchemaIndicator, forKey: .regionSchemaIndicator)
        try container.encode(exchangeRate, forKey: .exchangeRate)
    }

    /// Parses markup from either basis points (e.g., "320") or percentage (e.g., "3.2").
    /// Returns a String representing the percentage value formatted with two decimal places (e.g., "3.20").
    private static func parseMarkup(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        // Determine numeric value first (in percent units)
        let percentValue: Decimal
        if trimmed.contains(".") || trimmed.contains(",") {
            // Normalize comma to dot if present and parse directly as percentage
            let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
            percentValue = Decimal(string: normalized) ?? 0
        } else if let bp = Decimal(string: trimmed) { // basis points -> percent
            percentValue = bp / 100
        } else {
            percentValue = 0
        }

        // Format to two decimal places using a stable POSIX locale
        let ns = NSDecimalNumber(decimal: percentValue)
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        formatter.numberStyle = .decimal
        // Ensure decimal separator is a dot regardless of device locale
        formatter.decimalSeparator = "."
        return formatter.string(from: ns) ?? ns.stringValue
    }

    /// Returns a human-readable comparison string using `exchangeRateDecimal`, e.g. `"1 CZK = 0.0419 EUR"`.
    ///
    /// - Parameters:
    ///   - sourceCurrencyCode: The alphabetic code of the source currency (e.g., "CZK").
    ///   - assumesTargetPerSource: If `true`, `exchangeRateDecimal` is interpreted as target-per-source.
    ///     If `false`, the rate is inverted (source-per-target).
    ///   - fractionDigits: The number of fraction digits to display (default: 4).
    /// - Returns: A string in the format `"1 <source> = X <target>"`.
    public func formattedComparison(
        from sourceCurrencyCode: String,
        assumesTargetPerSource: Bool = false,
        fractionDigits: Int = 4
    ) -> String {
        let rate: Decimal

        let exchangeRateDecimal = Decimal(string: exchangeRate) ?? 0

        if assumesTargetPerSource {
            rate = exchangeRateDecimal
        } else {
            if exchangeRateDecimal == 0 { return "1 \(sourceCurrencyCode) = 0 \(currencyCode.rawValue)" }
            rate = 1 / exchangeRateDecimal
        }

        let ns = NSDecimalNumber(decimal: rate)
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        formatter.minimumIntegerDigits = 1
        formatter.numberStyle = .decimal
        let rateString = formatter.string(from: ns) ?? ns.stringValue
        return "1 \(sourceCurrencyCode) = \(rateString) \(currencyCode.rawValue)"
    }
}
