import Foundation

final class GpTomLog {
    static var enabled = false

    static func i(_ msg: String, _ data: [String: Any?] = [:]) { log("I", msg, data) }
    static func d(_ msg: String, _ data: [String: Any?] = [:]) { log("D", msg, data) }
    static func w(_ msg: String, _ data: [String: Any?] = [:]) { log("W", msg, data) }
    static func e(_ msg: String, _ data: [String: Any?] = [:]) { log("E", msg, data) }

    private static func log(_ lvl: String, _ msg: String, _ data: [String: Any?]) {
        guard enabled else { return }
        if data.isEmpty {
            NSLog("ADT_GP_TOM [\(lvl)] \(msg)")
        } else {
            NSLog("ADT_GP_TOM [\(lvl)] \(msg) \(data)")
        }
    }
}
