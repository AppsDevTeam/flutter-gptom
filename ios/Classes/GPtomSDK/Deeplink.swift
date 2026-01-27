//
//  Deeplink.swift
//  deeplinks
//
//  Created by Jan Švec on 13.03.2024.
//

import Foundation

public enum Deeplink: Sendable {
    case createTransaction(CreateTransactionParams)
    case cancelTransaction(CancelTransactionParams)
    case refundTransaction(RefundTransactionParams)
    case transactionDetail(TransactionDetailParams)
    case closeBatch(CloseBatchParams)
    case batchDetail(BatchDetailParams)
    case login(LoginParams)
    case status(StatusParams)

    public static func from(url: URL) -> Deeplink? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let params = convertQueryToDictionary(queryItems: components?.queryItems ?? [])

        let urlString = url.absoluteString

        if urlString.contains("transaction/create") {
            return CreateTransactionParams(params: params).flatMap { .createTransaction($0) }
        } else if urlString.contains("transaction/cancel") {
            return CancelTransactionParams(params: params).flatMap { .cancelTransaction($0) }
        } else if urlString.contains("transaction/detail") {
            return TransactionDetailParams(params: params).flatMap { .transactionDetail($0) }
        } else if urlString.contains("transaction/refund") {
            return RefundTransactionParams(params: params).flatMap { .refundTransaction($0) }
        } else if urlString.contains("batch/close") {
            return CloseBatchParams(params: params).flatMap { .closeBatch($0) }
        } else if urlString.contains("batch/detail") {
            return BatchDetailParams(params: params).flatMap { .batchDetail($0) }
        } else if urlString.contains("login") {
            return LoginParams(params: params).flatMap { .login($0) }
        } else if urlString.contains("status") {
            return StatusParams(params: params).flatMap { .status($0) }
        } else {
            return nil
        }
    }

    private static func convertQueryToDictionary(queryItems: [URLQueryItem]) -> [String: String] {
        var items = [String: String]()

        for item in queryItems {
            items[item.name] = item.value?.removingPercentEncoding
        }

        return items
    }

    public var clientID: String? {
        switch self {
        case .createTransaction(let params):
            return params.clientID
        case .cancelTransaction(let params):
            return params.clientID
        case .refundTransaction(let params):
            return params.clientID
        case .closeBatch(let params):
            return params.clientID
        default:
            return nil
        }
    }

    public var redirectUrl: String? {
        switch self {
        case .createTransaction(let params):
            return params.redirectUrl
        case .cancelTransaction(let params):
            return params.redirectUrl
        case .refundTransaction(let params):
            return params.redirectUrl
        case .status(let params):
            return params.redirectUrl
        case .closeBatch(let params):
            return params.redirectUrl
        default:
            return nil
        }
    }
}

// gptom://transaction/refund
public typealias RefundTransactionParams = CreateTransactionParams

// gptom://transaction/create
public struct CreateTransactionParams: Sendable {
    // optional id that can be used to access transaction detail instead of amsId.
    // can only be used locally on the device that created the transaction
    public let requestID: String?

    public let amount: Amount
    public let clientID: String?
    public let referenceNumber: String?
    public let printByPaymentApp: Bool?
    public let tipAmount: Amount?
    public let redirectUrl: String?
    public let tipCollect: Bool?
    public let transactionType: TransactionType?

    public let preferableReceiptType: ReceiptOption?
    public let clientPhone: String?
    public let clientEmail: String?
    public let orderId: String?

    public init(
        requestID: String? = nil,
        amount: Amount,
        clientID: String? = nil,
        referenceNumber: String? = nil,
        printByPaymentApp: Bool? = nil,
        tipAmount: Amount? = nil,
        redirectUrl: String? = nil,
        tipCollect: Bool? = nil,
        preferableReceiptType: ReceiptOption? = nil,
        clientPhone: String? = nil,
        clientEmail: String? = nil,
        orderId: String? = nil,
        transactionType: TransactionType? = nil)
    {
        self.requestID = requestID
        self.amount = amount
        self.referenceNumber = referenceNumber
        self.orderId = orderId
        self.clientID = clientID
        self.printByPaymentApp = printByPaymentApp
        self.tipAmount = tipAmount
        self.redirectUrl = redirectUrl
        self.tipCollect = tipCollect
        self.preferableReceiptType = preferableReceiptType
        self.clientPhone = clientPhone
        self.clientEmail = clientEmail
        self.transactionType = transactionType
    }

    init?(params: [String: String]) {
        guard let amount = params["amount"].flatMap({ Int64($0) }) else { return nil }
        self.amount = Decimal(amount) / 100

        requestID = params["requestID"]
        clientID = params["clientID"]
        referenceNumber = params["originReferenceNum"]
        printByPaymentApp = params["printByPaymentApp"].flatMap { Bool($0) }
        tipAmount = params["tipAmount"].flatMap { Decimal(Int64($0) ?? 0) / 100 }
        redirectUrl = params["redirectUrl"]
        tipCollect = params["tipCollect"].flatMap { Bool($0) }
        preferableReceiptType = params["preferableReceiptType"].flatMap { ReceiptOption(rawValue: $0) }
        clientPhone = params["clientPhone"]
        clientEmail = params["clientEmail"]
        orderId = nil
        transactionType = params["transactionType"].flatMap { TransactionType(rawValue: $0) }
    }
}

// gptom://transaction/cancel
public struct CancelTransactionParams: Sendable {
    // optional id that can be used to access transaction detail instead of amsId.
    // can only be used locally on the device that created the transaction
    public let requestID: String?

    public let clientID: String?
    public let amsID: String
    public let redirectUrl: String?
    public let printByPaymentApp: Bool?

    public let preferableReceiptType: ReceiptOption?
    public let clientPhone: String?
    public let clientEmail: String?

    public init(
        requestID: String? = nil,
        clientID: String? = nil,
        amsID: String,
        printByPaymentApp: Bool? = nil,
        redirectUrl: String? = nil,
        preferableReceiptType: ReceiptOption? = nil,
        clientPhone: String? = nil,
        clientEmail: String? = nil,
        orderId: String? = nil)
    {
        self.requestID = requestID
        self.clientID = clientID
        self.printByPaymentApp = printByPaymentApp
        self.amsID = amsID
        self.redirectUrl = redirectUrl
        self.preferableReceiptType = preferableReceiptType
        self.clientPhone = clientPhone
        self.clientEmail = clientEmail
    }

    init?(params: [String: String]) {
        clientID = params["clientID"]

        guard let amsID = params["amsID"] else { return nil }
        self.amsID = amsID

        requestID = params["requestID"]

        redirectUrl = params["redirectUrl"]
        printByPaymentApp = params["printByPaymentApp"].flatMap { Bool($0) }

        preferableReceiptType = params["preferableReceiptType"].flatMap { ReceiptOption(rawValue: $0) }
        clientPhone = params["clientPhone"]
        clientEmail = params["clientEmail"]
    }
}

// gptom://transaction/detail
public struct TransactionDetailParams: Sendable {
    public let amsID: String?
    public let requestID: String?

    public init?(params: [String: String]) {
        amsID = params["amsID"]
        requestID = params["requestID"]

        if amsID == nil && requestID == nil {
            return nil
        }
    }

    public init(amsID: String? = nil, requestID: String? = nil) {
        self.amsID = amsID
        self.requestID = requestID
    }
}

// gptom://batch/close
public struct CloseBatchParams: Sendable {
    public let clientID: String?
    public let redirectUrl: String?

    public let printByPaymentApp: Bool?
    public let preferableReceiptType: ReceiptOption?
    public let clientPhone: String?
    public let clientEmail: String?

    public init(clientID: String?,
                redirectUrl: String?,
                printByPaymentApp: Bool?,
                preferableReceiptType: ReceiptOption?,
                clientPhone: String?,
                clientEmail: String?)
    {
        self.clientID = clientID
        self.redirectUrl = redirectUrl
        self.printByPaymentApp = printByPaymentApp
        self.preferableReceiptType = preferableReceiptType
        self.clientEmail = clientEmail
        self.clientPhone = clientPhone
    }

    init?(params: [String: String]) {
        clientID = params["clientID"]
        redirectUrl = params["redirectUrl"]

        printByPaymentApp = params["printByPaymentApp"].flatMap { Bool($0) }
        preferableReceiptType = params["preferableReceiptType"].flatMap { ReceiptOption(rawValue: $0) }
        clientPhone = params["clientPhone"]
        clientEmail = params["clientEmail"]
    }
}

// gptom://batch/detail
public struct BatchDetailParams: Sendable {
    public let amsID: String

    init?(params: [String: String]) {
        guard let amsID = params["amsID"] else { return nil }
        self.amsID = amsID
    }
}

// gptom://login
public struct LoginParams: Sendable {
    public let username: String
    public let password: String
    public let tid: String?

    init?(params: [String: String]) {
        guard
            let username = params["username"],
            let password = params["password"]
        else { return nil }

        self.username = username
        self.password = password

        tid = params["tid"]
    }
}

// gptom://status
public struct StatusParams: Sendable {
    public let redirectUrl: String

    init?(params: [String: String]) {
        guard
            let redirectUrl = params["redirectUrl"]
        else { return nil }

        self.redirectUrl = redirectUrl
    }
}
