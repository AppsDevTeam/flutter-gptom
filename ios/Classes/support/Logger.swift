import Foundation

final class GpTomLog {
    /// Receives every log line once a Dart listener is attached.
    typealias Sink = ([String: Any]) -> Void

    static var enabled = false

    /// Lines kept while no Dart listener is attached; the oldest are dropped.
    private static let bufferLimit = 200

    private static let lock = NSLock()
    private static var buffer: [[String: Any]] = []
    private static var sink: Sink?

    /// Starts mirroring log lines to Dart.
    ///
    /// Whatever was buffered since the last detach is flushed first: the plugin
    /// already logs from init(), which runs before Dart can subscribe, and those
    /// are exactly the lines worth having.
    static func attachSink(_ newSink: @escaping Sink) {
        lock.lock()
        sink = newSink
        let pending = buffer
        buffer.removeAll()
        lock.unlock()

        for entry in pending {
            DispatchQueue.main.async { newSink(entry) }
        }
    }

    static func detachSink() {
        lock.lock()
        sink = nil
        lock.unlock()
    }

    static func i(_ msg: String, _ data: [String: Any?] = [:]) { log("info", msg, data) }
    static func d(_ msg: String, _ data: [String: Any?] = [:]) { log("debug", msg, data) }
    static func w(_ msg: String, _ data: [String: Any?] = [:]) { log("warning", msg, data) }
    static func e(_ msg: String, _ data: [String: Any?] = [:]) { log("error", msg, data) }

    private static func log(_ level: String, _ msg: String, _ data: [String: Any?]) {
        guard enabled else { return }

        if data.isEmpty {
            NSLog("%@", "ADT_GP_TOM [\(level)] \(msg)")
        } else {
            NSLog("%@", "ADT_GP_TOM [\(level)] \(msg) \(data)")
        }

        emit(level, msg, data)
    }

    private static func emit(_ level: String, _ msg: String, _ data: [String: Any?]) {
        var entry: [String: Any] = [
            JsonKeys.level: level,
            JsonKeys.message: msg,
            JsonKeys.createdAtMs: Int(Date().timeIntervalSince1970 * 1000),
        ]

        if !data.isEmpty {
            entry[JsonKeys.data] = "\(data)"
        }

        // Buffering and handing the entry over happen under the same lock, so a
        // listener attaching right now either flushes this entry or receives it
        // directly - it cannot fall between the two.
        lock.lock()
        let currentSink = sink

        if currentSink == nil {
            if buffer.count >= bufferLimit { buffer.removeFirst() }
            buffer.append(entry)
        }
        lock.unlock()

        if let currentSink {
            DispatchQueue.main.async { currentSink(entry) }
        }
    }
}
