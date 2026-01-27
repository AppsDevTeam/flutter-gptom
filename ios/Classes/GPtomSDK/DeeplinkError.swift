//
//  DeeplinkError.swift
//  GPtomSDK
//
//  Created by Jan Švec on 30.10.2025.
//

public enum DeeplinkError: String, Equatable, CaseIterable, Codable, Sendable {
    case failed
    case networkError
    case invalidClientId
    case merchantInfoMissing
    case failedTapToPay
    case failedToCloseBatch
}
