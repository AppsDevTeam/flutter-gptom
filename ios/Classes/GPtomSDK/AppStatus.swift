//
//  AppStatus.swift
//  GPtomSDK
//
//  Created by Jan Švec on 19.05.2025.
//

public struct AppStatus: Codable, Equatable, Sendable {
    public let appVersion: String
    public let userInfo: UserInfo?
    public var isLoggedIn: Bool { userInfo != nil }

    public init(appVersion: String,
                userInfo: UserInfo? = nil)
    {
        self.appVersion = appVersion
        self.userInfo = userInfo
    }
}

public struct UserInfo: Codable, Equatable, Sendable {
    public let clientId: String
    public let email: String
    public let businessId: String?
    public let vatId: String?
    public let tid: String
    public let mid: String
    public let tipEnabled: Bool
    public let printerAvailable: Bool
    public let manualTransactionRestricted: Bool
    public let merchantLocation: Address

    public init(
        clientId: String,
        email: String,
        businessId: String? = nil,
        vatId: String? = nil,
        tid: String,
        mid: String,
        tipEnabled: Bool,
        printerAvailable: Bool,
        manualTransactionRestricted: Bool,
        merchantLocation: Address
    ) {
        self.clientId = clientId
        self.email = email
        self.businessId = businessId
        self.vatId = vatId
        self.tid = tid
        self.mid = mid
        self.tipEnabled = tipEnabled
        self.printerAvailable = printerAvailable
        self.manualTransactionRestricted = manualTransactionRestricted
        self.merchantLocation = merchantLocation
    }
}

public struct Address: Codable, Equatable, Sendable {
    public var city: String?
    public var county: String?
    public var house: String?
    public var location: String?
    public var street: String?
    public var zip: String?

    public var streetWithNumber: String? {
        if let street, let house {
            return "\(street) \(house)"
        }

        return nil
    }

    public init(city: String? = nil,
                county: String? = nil,
                house: String? = nil,
                location: String? = nil,
                street: String? = nil,
                zip: String? = nil)
    {
        self.city = city
        self.county = county
        self.house = house
        self.location = location
        self.street = street
        self.zip = zip
    }
}
