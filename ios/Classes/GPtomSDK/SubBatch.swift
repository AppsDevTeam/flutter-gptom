import Foundation

public struct SubBatch: Codable, Equatable, Sendable {
    public let closeBatchNumber: String?
    public let saleAmount: Amount?
    public let saleCount: Double?
    public let totalAmount: Amount?
    public let totalCount: Double?
    public let voidAmount: Amount?
    public let voidCount: Double?

    public init(closeBatchNumber: String? = nil,
                saleAmount: Amount? = nil,
                saleCount: Double? = nil,
                totalAmount: Amount? = nil,
                totalCount: Double? = nil,
                voidAmount: Amount? = nil,
                voidCount: Double? = nil)
    {
        self.closeBatchNumber = closeBatchNumber
        self.saleAmount = saleAmount
        self.saleCount = saleCount
        self.totalAmount = totalAmount
        self.totalCount = totalCount
        self.voidAmount = voidAmount
        self.voidCount = voidCount
    }

    public var hasAnyTransactions: Bool {
        (totalCount ?? 0) > 0
    }
}
