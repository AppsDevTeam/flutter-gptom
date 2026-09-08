import Foundation

public struct Channels {
    private init() {}

    public static let methods = "adt_gptom/methods"
    public static let events = "adt_gptom/events"

    /// Plugin's own log lines, mirrored to Dart for on-device diagnostics.
    public static let logs = "adt_gptom/logs"
}
