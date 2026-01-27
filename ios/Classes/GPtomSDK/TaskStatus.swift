//
//  TaskStatus.swift
//
//
//  Created by Jan Švec on 30.07.2024.
//

import Foundation

public enum TaskStatus: String, Equatable, CaseIterable, Codable, Sendable {
    case completed = "COMPLETED"
    case error = "ERROR"
    case cancelled = "CANCELLED"
}
