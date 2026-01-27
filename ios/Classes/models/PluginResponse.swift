enum PluginResponse {
    case success(_ data: Any?)
    case error(code: String, message: String)

    func toMap() -> [String: Any] {
        switch self {
        case .success(let data):
            return [
                JsonKeys.code: ResultCodes.ok,
                JsonKeys.data: data ?? NSNull(),
            ]
        case .error(let code, let message):
            return [
                JsonKeys.code: code,
                JsonKeys.message: message,
                JsonKeys.data: NSNull(),
            ]
        }
    }
}
