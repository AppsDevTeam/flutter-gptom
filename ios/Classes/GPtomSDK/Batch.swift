import Foundation

public struct Batch: Codable, Equatable, Sendable {
    /** Internal id of the batch, OPEN for pseudo batch with open transactions */
    public var amsId: String

    /** External batch number, can be null if not provided */
    public let batchNumber: String?

    public let communicationId: String?

    public let currency: String?

    public var date: Date?

    public var firstTransactionDate: Date?

    public let invalidCount: Double?

    public var previousBatchDate: Date?

    public let saleAmount: Amount?

    public let saleCount: Double?

    public let subBatches: SubBatches?

    public let totalAmount: Amount?

    public let totalCount: Double?

    public let voidAmount: Amount?

    public let voidCount: Double?

    public var isOpen: Bool { self.amsId == "OPEN" }

    public let tipAmount: Amount?

    public let tipCount: Int?

    public let tipAverage: Amount?

    public let tipAveragePercentage: Double?

    public init(amsId: String,
                batchNumber: String? = nil,
                communicationId: String? = nil,
                currency: String? = nil,
                date: Date? = nil,
                firstTransactionDate: Date? = nil,
                invalidCount: Double? = nil,
                previousBatchDate: Date? = nil,
                saleAmount: Amount? = nil,
                saleCount: Double? = nil,
                subBatches: SubBatches? = nil,
                totalAmount: Amount? = nil,
                totalCount: Double? = nil,
                voidAmount: Amount? = nil,
                voidCount: Double? = nil,
                tipAmount: Amount? = nil,
                tipCount: Int? = nil,
                tipAverage: Amount? = nil,
                tipAveragePercentage: Double? = nil)
    {
        self.amsId = amsId
        self.batchNumber = batchNumber
        self.communicationId = communicationId
        self.currency = currency
        self.date = date
        self.firstTransactionDate = firstTransactionDate
        self.invalidCount = invalidCount
        self.previousBatchDate = previousBatchDate
        self.saleAmount = saleAmount
        self.saleCount = saleCount
        self.subBatches = subBatches
        self.totalAmount = totalAmount
        self.totalCount = totalCount
        self.voidAmount = voidAmount
        self.voidCount = voidCount
        self.tipAmount = tipAmount
        self.tipCount = tipCount
        self.tipAverage = tipAverage
        self.tipAveragePercentage = tipAveragePercentage
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.amsId = try container.decode(String.self, forKey: .amsId)
        self.batchNumber = try container.decodeIfPresent(String.self, forKey: .batchNumber)
        self.communicationId = try container.decodeIfPresent(String.self, forKey: .communicationId)
        self.currency = try container.decodeIfPresent(String.self, forKey: .currency)

        if let date = try container.decodeIfPresent(String.self, forKey: .date) {
            self.date = ISO.iso8601DateFormatter.date(from: date)
        }

        if let date = try container.decodeIfPresent(String.self, forKey: .firstTransactionDate) {
            self.firstTransactionDate = ISO.iso8601DateFormatter.date(from: date)
        }

        if let date = try container.decodeIfPresent(String.self, forKey: .previousBatchDate) {
            self.previousBatchDate = ISO.iso8601DateFormatter.date(from: date)
        }

        self.invalidCount = try container.decodeIfPresent(Double.self, forKey: .invalidCount)
        self.saleAmount = try container.decodeIfPresent(Amount.self, forKey: .saleAmount)
        self.saleCount = try container.decodeIfPresent(Double.self, forKey: .saleCount)
        self.subBatches = try container.decodeIfPresent(SubBatches.self, forKey: .subBatches)
        self.totalAmount = try container.decodeIfPresent(Amount.self, forKey: .totalAmount)
        self.totalCount = try container.decodeIfPresent(Double.self, forKey: .totalCount)
        self.voidAmount = try container.decodeIfPresent(Amount.self, forKey: .voidAmount)
        self.voidCount = try container.decodeIfPresent(Double.self, forKey: .voidCount)
        self.tipAmount = try container.decodeIfPresent(Amount.self, forKey: .tipAmount)
        self.tipCount = try container.decodeIfPresent(Int.self, forKey: .tipCount)
        self.tipAverage = try container.decodeIfPresent(Amount.self, forKey: .tipAverage)
        self.tipAveragePercentage = try container.decodeIfPresent(Double.self, forKey: .tipAveragePercentage)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.amsId, forKey: .amsId)
        try container.encodeIfPresent(self.batchNumber, forKey: .batchNumber)
        try container.encodeIfPresent(self.communicationId, forKey: .communicationId)
        try container.encodeIfPresent(self.currency, forKey: .currency)

        let date = date.flatMap { ISO.iso8601DateFormatter.string(from: $0) }
        try container.encodeIfPresent(date, forKey: .date)

        let firstTransactionDate = firstTransactionDate.flatMap { ISO.iso8601DateFormatter.string(from: $0) }
        try container.encodeIfPresent(firstTransactionDate, forKey: .firstTransactionDate)

        try container.encodeIfPresent(self.invalidCount, forKey: .invalidCount)

        let previousBatchDate = previousBatchDate.flatMap { ISO.iso8601DateFormatter.string(from: $0) }
        try container.encodeIfPresent(previousBatchDate, forKey: .previousBatchDate)

        try container.encodeIfPresent(self.saleAmount, forKey: .saleAmount)
        try container.encodeIfPresent(self.saleCount, forKey: .saleCount)
        try container.encodeIfPresent(self.subBatches, forKey: .subBatches)
        try container.encodeIfPresent(self.totalAmount, forKey: .totalAmount)
        try container.encodeIfPresent(self.totalCount, forKey: .totalCount)
        try container.encodeIfPresent(self.voidAmount, forKey: .voidAmount)
        try container.encodeIfPresent(self.voidCount, forKey: .voidCount)
        try container.encodeIfPresent(self.tipAmount, forKey: .tipAmount)
        try container.encodeIfPresent(self.tipCount, forKey: .tipCount)
        try container.encodeIfPresent(self.tipAverage, forKey: .tipAverage)
        try container.encodeIfPresent(self.tipAveragePercentage, forKey: .tipAveragePercentage)
    }

    public enum CodingKeys: CodingKey {
        case amsId
        case batchNumber
        case communicationId
        case currency
        case date
        case firstTransactionDate
        case invalidCount
        case previousBatchDate
        case saleAmount
        case saleCount
        case subBatches
        case totalAmount
        case totalCount
        case voidAmount
        case voidCount
        case tipAmount
        case tipCount
        case tipAverage
        case tipAveragePercentage
    }
}
