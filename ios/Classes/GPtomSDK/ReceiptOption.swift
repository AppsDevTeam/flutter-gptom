//
//  ReceiptOption.swift
//  GPtomSDK
//
//  Created by Jan Švec on 28.08.2025.
//

public enum ReceiptOption: String, CaseIterable, Codable, Sendable {
    case sms = "SMS"
    case email = "EMAIL"
    case qr = "QR"
    case print = "PRINT"
}
