//
//  ReceiptForApp2App.swift
//
//
//  Created by Jan Švec on 11.07.2024.
//

import Foundation

public struct TransactionData: Codable, Sendable {
    public let batchNumber: String?
    public let receiptNumber: String?
    public let terminalID: String?
    public let emvAid: String?
    public let emvAppLabel: String?
    public let cardNumber: String?
    public let transactionType: TransactionType?
    public let currencyCode: String?
    public let amount: String?
    public let totalAmount: String?
    public let pinOk: Bool?
    public let authorizationCode: String?
    public let sequenceNumber: String?
    public var date: Date?
    public let cardType: CardType?
    public let referenceNumber: String?
    public let transactionID: String?
    public let tipAmount: String?
    public let result: Int?
    public let cardEntryMode: String?
    public let merchantID: String?
    public let amsID: String? // Internal GP tom transaction ID, used for cancelling transaction
    public let blikCode: String? // Code used in BLIK transaction
    public let blikTransactionRef: String?
    public let dccData: DCCOptionsWrapper?

    public init(batchNumber: String?,
                receiptNumber: String?,
                terminalID: String?,
                emvAid: String?,
                emvAppLabel: String?,
                cardNumber: String?,
                transactionType: TransactionType?,
                currencyCode: String?,
                amount: String?,
                totalAmount: String?,
                pinOk: Bool?,
                sequenceNumber: String?,
                date: Date?,
                cardType: CardType?,
                referenceNumber: String?,
                transactionID: String?,
                tipAmount: String?,
                result: Int?,
                cardEntryMode: String?,
                merchantID: String?,
                amsID: String?,
                authorizationCode: String?,
                blikCode: String?,
                blikTransactionRef: String?,
                dccData: DCCOptionsWrapper?)
    {
        self.batchNumber = batchNumber
        self.receiptNumber = receiptNumber
        self.terminalID = terminalID
        self.emvAid = emvAid
        self.emvAppLabel = emvAppLabel
        self.cardNumber = cardNumber
        self.transactionType = transactionType
        self.currencyCode = currencyCode
        self.amount = amount
        self.totalAmount = totalAmount
        self.pinOk = pinOk
        self.sequenceNumber = sequenceNumber
        self.date = date
        self.cardType = cardType
        self.referenceNumber = referenceNumber
        self.transactionID = transactionID
        self.tipAmount = tipAmount
        self.result = result
        self.cardEntryMode = cardEntryMode
        self.merchantID = merchantID
        self.amsID = amsID
        self.authorizationCode = authorizationCode
        self.blikCode = blikCode
        self.blikTransactionRef = blikTransactionRef
        self.dccData = dccData
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.batchNumber = try container.decodeIfPresent(String.self, forKey: .batchNumber)
        self.receiptNumber = try container.decodeIfPresent(String.self, forKey: .receiptNumber)
        self.terminalID = try container.decodeIfPresent(String.self, forKey: .terminalID)
        self.emvAid = try container.decodeIfPresent(String.self, forKey: .emvAid)
        self.emvAppLabel = try container.decodeIfPresent(String.self, forKey: .emvAppLabel)
        self.cardNumber = try container.decodeIfPresent(String.self, forKey: .cardNumber)
        self.transactionType = try container.decodeIfPresent(TransactionType.self, forKey: .transactionType)
        self.currencyCode = try container.decodeIfPresent(String.self, forKey: .currencyCode)
        self.amount = try container.decodeIfPresent(String.self, forKey: .amount)
        self.totalAmount = try container.decodeIfPresent(String.self, forKey: .totalAmount)
        self.pinOk = try container.decodeIfPresent(Bool.self, forKey: .pinOk)
        self.authorizationCode = try container.decodeIfPresent(String.self, forKey: .authorizationCode)
        self.sequenceNumber = try container.decodeIfPresent(String.self, forKey: .sequenceNumber)

        if let date = try container.decodeIfPresent(String.self, forKey: .date) {
            self.date = ISO.iso8601DateFormatter.date(from: date)
        }

        self.cardType = try container.decodeIfPresent(CardType.self, forKey: .cardType)
        self.referenceNumber = try container.decodeIfPresent(String.self, forKey: .referenceNumber)
        self.transactionID = try container.decodeIfPresent(String.self, forKey: .transactionID)
        self.tipAmount = try container.decodeIfPresent(String.self, forKey: .tipAmount)
        self.result = try container.decodeIfPresent(Int.self, forKey: .result)
        self.cardEntryMode = try container.decodeIfPresent(String.self, forKey: .cardEntryMode)
        self.merchantID = try container.decodeIfPresent(String.self, forKey: .merchantID)
        self.amsID = try container.decodeIfPresent(String.self, forKey: .amsID)
        self.blikCode = try container.decodeIfPresent(String.self, forKey: .blikCode)
        self.blikTransactionRef = try container.decodeIfPresent(String.self, forKey: .blikTransactionRef)
        self.dccData = try container.decodeIfPresent(DCCOptionsWrapper.self, forKey: .dccData)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.batchNumber, forKey: .batchNumber)
        try container.encodeIfPresent(self.receiptNumber, forKey: .receiptNumber)
        try container.encodeIfPresent(self.terminalID, forKey: .terminalID)
        try container.encodeIfPresent(self.emvAid, forKey: .emvAid)
        try container.encodeIfPresent(self.emvAppLabel, forKey: .emvAppLabel)
        try container.encodeIfPresent(self.cardNumber, forKey: .cardNumber)
        try container.encodeIfPresent(self.transactionType, forKey: .transactionType)
        try container.encodeIfPresent(self.currencyCode, forKey: .currencyCode)
        try container.encodeIfPresent(self.amount, forKey: .amount)
        try container.encodeIfPresent(self.totalAmount, forKey: .totalAmount)
        try container.encodeIfPresent(self.pinOk, forKey: .pinOk)
        try container.encodeIfPresent(self.authorizationCode, forKey: .authorizationCode)
        try container.encodeIfPresent(self.sequenceNumber, forKey: .sequenceNumber)

        let date = date.flatMap { ISO.iso8601DateFormatter.string(from: $0) }
        try container.encodeIfPresent(date, forKey: .date)

        try container.encodeIfPresent(self.cardType, forKey: .cardType)
        try container.encodeIfPresent(self.referenceNumber, forKey: .referenceNumber)
        try container.encodeIfPresent(self.transactionID, forKey: .transactionID)
        try container.encodeIfPresent(self.tipAmount, forKey: .tipAmount)
        try container.encodeIfPresent(self.result, forKey: .result)
        try container.encodeIfPresent(self.cardEntryMode, forKey: .cardEntryMode)
        try container.encodeIfPresent(self.merchantID, forKey: .merchantID)
        try container.encodeIfPresent(self.amsID, forKey: .amsID)
        try container.encodeIfPresent(self.blikCode, forKey: .blikCode)
        try container.encodeIfPresent(self.blikTransactionRef, forKey: .blikTransactionRef)
        try container.encodeIfPresent(self.dccData, forKey: .dccData)
    }

    enum CodingKeys: CodingKey {
        case batchNumber
        case receiptNumber
        case terminalID
        case emvAid
        case emvAppLabel
        case cardNumber
        case transactionType
        case currencyCode
        case amount
        case totalAmount
        case pinOk
        case authorizationCode
        case sequenceNumber
        case date
        case cardType
        case referenceNumber
        case transactionID
        case tipAmount
        case result
        case cardEntryMode
        case merchantID
        case amsID
        case blikCode
        case blikTransactionRef
        case dccData
    }
}
