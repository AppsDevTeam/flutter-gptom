import Foundation

public enum TaskStatus: String, Equatable, CaseIterable, Codable, Sendable {
    case completed = "COMPLETED"
    case error = "ERROR"
    case cancelled = "CANCELLED"
}
