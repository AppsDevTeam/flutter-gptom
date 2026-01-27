//
//  CardType.swift
//
//
//  Created by Jan Švec on 30.07.2024.
//

import Foundation

public enum CardType: String, Equatable, CaseIterable, Codable, Sendable {
    case discover = "DISCOVER"
    case jcbandVisa = "JCBANDVISA"
    case mastercard = "MASTERCARD"
    case visa = "VISA"
    case amex = "AMEX"
    case jcb = "JCB"
    case troy = "TROY"
    case unionPay = "UNIONPAY"
    case ruPay = "RUPAY"
    case pure = "PURE"
    case unknown = "UNKNOWN"
}
