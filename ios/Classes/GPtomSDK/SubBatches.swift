//
//  SubBatches.swift
//
//
//  Created by Jan Švec on 05.05.2023.
//

import Foundation

public struct SubBatches: Codable, Equatable, Sendable {
    public let card: SubBatch?
    public let goCrypto: SubBatch?
    public let cash: SubBatch?
    public let qr: SubBatch?
    public let blik: SubBatch?
    public let gateway: SubBatch?

    public enum CodingKeys: String, CodingKey {
        case card = "CARD"
        case goCrypto = "GO_CRYPTO"
        case cash = "CASH"
        case qr = "ACCOUNT_PAYMENT"
        case blik = "BLIK_PAYMENT"
        case gateway = "PAYMENT_GATEWAY"
    }

    public init(card: SubBatch? = nil,
                goCrypto: SubBatch? = nil,
                cash: SubBatch? = nil,
                qr: SubBatch? = nil,
                blik: SubBatch? = nil,
                gateway: SubBatch? = nil)
    {
        self.card = card
        self.goCrypto = goCrypto
        self.cash = cash
        self.qr = qr
        self.blik = blik
        self.gateway = gateway
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.card = try container.decodeIfPresent(SubBatch.self, forKey: .card)
        self.goCrypto = try container.decodeIfPresent(SubBatch.self, forKey: .goCrypto)
        self.cash = try container.decodeIfPresent(SubBatch.self, forKey: .cash)
        self.qr = try container.decodeIfPresent(SubBatch.self, forKey: .qr)
        self.blik = try container.decodeIfPresent(SubBatch.self, forKey: .blik)
        self.gateway = try container.decodeIfPresent(SubBatch.self, forKey: .gateway)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.card, forKey: .card)
        try container.encodeIfPresent(self.goCrypto, forKey: .goCrypto)
        try container.encodeIfPresent(self.cash, forKey: .cash)
        try container.encodeIfPresent(self.qr, forKey: .qr)
        try container.encodeIfPresent(self.blik, forKey: .blik)
        try container.encodeIfPresent(self.gateway, forKey: .gateway)
    }
}
