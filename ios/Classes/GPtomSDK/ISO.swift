//
//  ISO.swift
//  deeplinks
//
//  Created by Jan Švec on 14.08.2024.
//

import Foundation

public enum ISO {
    public nonisolated(unsafe) static let iso8601DateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime,
                                   .withFractionalSeconds]
        return formatter
    }()
}
