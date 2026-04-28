import Foundation

public enum DccResulStatus: String, Codable, Sendable {
    // User accepted to convert currency
    case accepted = "ACCEPTED"
    // user declined conversion
    case notAccepted = "NOT_ACCEPTED"
    // DCC failed for any reason
    case notProcessed = "NOT_PROCESSED"
}

public struct DCCOptions: Codable, Equatable, Sendable {
    public let amount: String
    public let currencyCode: String
    public let effectiveRate: Decimal
    public let markUpRate: String
    public let regionSchemaIndicator: String
    public let txnId: String?
    public let isDecline: String?
    public let dccCurrencyExponent: String

    func copy(txnId: String? = nil, isDecline: Bool? = nil) -> Self {
        .init(amount: amount,
              currencyCode: currencyCode,
              effectiveRate: effectiveRate,
              markUpRate: markUpRate,
              regionSchemaIndicator: regionSchemaIndicator,
              txnId: txnId ?? self.txnId,
              isDecline: isDecline?.description ?? self.isDecline,
              dccCurrencyExponent: dccCurrencyExponent)
    }

    public func add(transactionId: String) -> Self {
        copy(txnId: transactionId)
    }

    public func accept(value: Bool) -> Self {
        copy(isDecline: !value)
    }
}

public struct DCCOptionsWrapper: Codable, Equatable, Sendable {
    public let original: DCCOptions?

    public let currency: Currency
    public let amount: Amount

    // - Examples: 320
    public let markup: Int

    // - Examples: "3.20%"
    public let markUpRatePercentage: String

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
    public let exchangeRate: Decimal

    public let status: DccResulStatus?

    private enum CodingKeys: String, CodingKey {
        case currency
        case amount
        case markup
        case regionSchemaIndicator
        case exchangeRate
        case status
    }

    public init(original: DCCOptions) throws {
        let currency = original.currencyCode.trimmingCharacters(in: .whitespacesAndNewlines)

        // If it's a 3-letter ISO code, attempt to construct Currency from ISO
        if currency.count == 3, let isoCurrency = Currency.from(code: currency.uppercased()) {
            self.currency = isoCurrency
        } else {
            // Otherwise treat as numeric code possibly left-padded with zeros
            let normalizedNumeric: String
            if currency.hasPrefix("0") {
                normalizedNumeric = String(currency.dropFirst())
            } else {
                normalizedNumeric = currency
            }
            guard let numericCurrency = Currency(rawValue: normalizedNumeric) else {
                throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.currency],
                                                        debugDescription: "Unsupported currency code: \(currency)"))
            }

            self.currency = numericCurrency
        }

        let exponent = max(0, Int(original.dccCurrencyExponent) ?? 2)
        guard let amountValue = DCCOptionsWrapper.decimalAmount(fromRaw: original.amount, exponent: exponent) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.amount],
                                                    debugDescription: "Failed parsing amount: \(original.amount) with exponent: \(exponent)"))
        }
        self.amount = amountValue

        guard let markup = DCCOptionsWrapper.parseMarkupBasisPoints(original.markUpRate) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.markup],
                                                    debugDescription: "Failed parsing markUpRate: \(original.markUpRate)"))
        }

        self.markup = markup
        self.markUpRatePercentage = DCCOptionsWrapper.markupToPercentageFunction(markup)

        guard let regionSchemaIndicator = Int(original.regionSchemaIndicator) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.regionSchemaIndicator],
                                                    debugDescription: "Failed parsing regionSchemaIndicator: \(original.regionSchemaIndicator)"))
        }

        self.regionSchemaIndicator = regionSchemaIndicator

        self.exchangeRate = original.effectiveRate
        self.original = original

        self.status = nil
    }

    public init(currency: Currency,
                amount: Decimal,
                markup: Int,
                regionSchemaIndicator: Int,
                exchangeRate: Decimal,
                status: DccResulStatus?,
                original: DCCOptions? = nil)
    {
        self.currency = currency
        self.amount = amount
        self.markup = markup
        self.markUpRatePercentage = DCCOptionsWrapper.markupToPercentageFunction(markup)
        self.regionSchemaIndicator = regionSchemaIndicator
        self.exchangeRate = exchangeRate
        self.status = status
        self.original = original
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let currency = try container.decode(String.self, forKey: .currency)
        self.currency = Currency.from(code: currency) ?? .EUR

        self.amount = try container.decode(Decimal.self, forKey: .amount)
        self.markup = try container.decode(Int.self, forKey: .markup)
        self.regionSchemaIndicator = try container.decode(Int.self, forKey: .regionSchemaIndicator)
        self.exchangeRate = try container.decode(Decimal.self, forKey: .exchangeRate)
        self.original = nil

        self.markUpRatePercentage = DCCOptionsWrapper.markupToPercentageFunction(markup)
        self.status = try container.decodeIfPresent(DccResulStatus.self, forKey: .status)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currency.isoCode, forKey: .currency)
        try container.encode(amount, forKey: .amount)
        try container.encode(markup, forKey: .markup)
        try container.encode(regionSchemaIndicator, forKey: .regionSchemaIndicator)
        try container.encode(exchangeRate, forKey: .exchangeRate)
        try container.encode(status, forKey: .status)
    }

    public func changeStatus(status: DccResulStatus) -> Self {
        .init(currency: currency,
              amount: amount,
              markup: markup,
              regionSchemaIndicator: regionSchemaIndicator,
              exchangeRate: exchangeRate,
              status: status,
              original: original)
    }

    private static func decimalAmount(fromRaw rawAmount: String, exponent: Int) -> Decimal? {
        let trimmed = rawAmount.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let sign: String
        let digitsPortion: Substring
        if let first = trimmed.first, first == "-" || first == "+" {
            sign = String(first)
            digitsPortion = trimmed.dropFirst()
        } else {
            sign = ""
            digitsPortion = Substring(trimmed)
        }

        guard !digitsPortion.isEmpty,
              digitsPortion.unicodeScalars.allSatisfy({ CharacterSet.decimalDigits.contains($0) })
        else {
            return nil
        }

        let digits = String(digitsPortion)
        let normalized: String

        if exponent == 0 {
            normalized = sign + digits
        } else if digits.count <= exponent {
            let zeros = String(repeating: "0", count: exponent - digits.count)
            normalized = "\(sign)0.\(zeros)\(digits)"
        } else {
            let integerEnd = digits.index(digits.endIndex, offsetBy: -exponent)
            let integerPart = digits[..<integerEnd]
            let fractionPart = digits[integerEnd...]
            normalized = "\(sign)\(integerPart).\(fractionPart)"
        }

        return Decimal(string: normalized)
    }

    /// Converts basis points markup into a percentage string (e.g., 320 -> "3.20%").
    private static func markupToPercentageFunction(_ markup: Int) -> String {
        let percentValue = Decimal(markup) / 100
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."

        let number = NSDecimalNumber(decimal: percentValue)
        return "\(formatter.string(from: number) ?? number.stringValue)%"
    }

    /// Parses markup from either basis points (e.g., "320") or percentage (e.g., "3.2")
    /// and returns basis points as Int.
    private static func parseMarkupBasisPoints(_ raw: String) -> Int? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmed.contains("."), !trimmed.contains(",") {
            return Int(trimmed)
        }

        let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
        guard let percent = Decimal(string: normalized) else { return nil }

        var basisPoints = percent * 100
        var rounded = Decimal()
        NSDecimalRound(&rounded, &basisPoints, 0, .plain)
        return NSDecimalNumber(decimal: rounded).intValue
    }

    /// Returns a human-readable comparison string using `exchangeRateDecimal`, e.g. `"1 CZK = 0.0419 EUR"`.
    ///
    /// - Parameters:
    ///   - sourceCurrencyCode: The alphabetic code of the source currency (e.g., "CZK").
    ///   - assumesTargetPerSource: If `true`, `exchangeRateDecimal` is interpreted as target-per-source.
    ///     If `false`, the rate is inverted (source-per-target).
    ///   - fractionDigits: The number of fraction digits to display (default: 4).
    /// - Returns: A string in the format `"1 <source> = X <target>"`.
    public func formattedComparison(from sourceCurrencyCode: String,
                                    assumesTargetPerSource: Bool = false,
                                    fractionDigits: Int = 4) -> String
    {
        let rate: Decimal

        if assumesTargetPerSource {
            rate = exchangeRate
        } else {
            if exchangeRate == 0 { return "1 \(sourceCurrencyCode) = 0 \(currency.isoCode)" }
            rate = 1 / exchangeRate
        }

        let ns = NSDecimalNumber(decimal: rate)
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        formatter.minimumIntegerDigits = 1
        formatter.numberStyle = .decimal
        let rateString = formatter.string(from: ns) ?? ns.stringValue
        return "1 \(sourceCurrencyCode) = \(rateString) \(currency.isoCode)"
    }
}
