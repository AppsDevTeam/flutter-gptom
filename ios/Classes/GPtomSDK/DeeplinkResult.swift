//
//  DeeplinkResult.swift
//  deeplinks
//
//  Created by Jan Švec on 11.07.2024.
//

import Foundation

public enum DeeplinkResult: Sendable {
    case createTransaction(TransactionData?, RefusalCode?, TaskStatus, DeeplinkError?)
    case refundTransaction(TransactionData?, RefusalCode?, TaskStatus, DeeplinkError?)
    case cancelTransaction(TransactionData?, RefusalCode?, TaskStatus, DeeplinkError?)
    case closeBatch(Batch?, TaskStatus, DeeplinkError?)
    case status(AppStatus?, TaskStatus)

    public static func from(url: URL) -> DeeplinkResult? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let params = convertQueryToDictionary(queryItems: components?.queryItems ?? [])

        let urlString = url.absoluteString

        if urlString.contains("transaction/create") {
            return parseTransactionResult(params: params)
                .flatMap { .createTransaction($0.0, $0.1, $0.2, $0.3) }

        } else if urlString.contains("transaction/cancel") {
            return parseTransactionResult(params: params)
                .flatMap { .cancelTransaction($0.0, $0.1, $0.2, $0.3) }

        } else if urlString.contains("transaction/refund") {
            return parseTransactionResult(params: params)
                .flatMap { .refundTransaction($0.0, $0.1, $0.2, $0.3) }

        } else if urlString.contains("batch/close") {
            guard let status = parseStatus(params: params)
            else {
                return nil
            }

            let error = parseError(params: params)

            let batch = params["batch"].flatMap { try? Batch.decode(from: $0) }

            return .closeBatch(batch, status, error)

        } else if urlString.contains("appStatus") {
            guard let status = parseStatus(params: params)
            else {
                return nil
            }

            let appStatus = params["appStatus"].flatMap { try? AppStatus.decode(from: $0) }
            return .status(appStatus, status)
        } else {
            return nil
        }
    }

    private static func parseStatus(params: [String: String]) -> TaskStatus? {
        return params["status"].flatMap { TaskStatus(rawValue: $0) }
    }

    private static func parseError(params: [String: String]) -> DeeplinkError? {
        return params["error"].flatMap { DeeplinkError(rawValue: $0) }
    }

    private static func parseTransactionResult(params: [String: String]) -> (TransactionData?, RefusalCode?, TaskStatus, DeeplinkError?)? {
        guard let status = parseStatus(params: params)
        else {
            return nil
        }

        let receipt = params["receipt"].flatMap { try? TransactionData.decode(from: $0) }
        let refusalCode = params["code"].flatMap { RefusalCode(rawValue: $0) }
        let error = parseError(params: params)

        return (receipt, refusalCode, status, error)
    }

    private static func convertQueryToDictionary(queryItems: [URLQueryItem]) -> [String: String] {
        var items = [String: String]()

        for item in queryItems {
            items[item.name] = item.value?.removingPercentEncoding
        }

        return items
    }
}

public extension Decodable {
    static func decode(from string: String) throws -> Self {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Self.self,
                                  from: Data(string.utf8))
    }
}

public extension Encodable {
    func toPrettyString() -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(self),
              let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
              let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        else { return "" }

        return String(decoding: jsonData, as: UTF8.self)
    }
}
