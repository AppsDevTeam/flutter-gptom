import Foundation

struct AppStatusMapper {
    private init() {}

    static func toMap(_ appStatus: AppStatus) -> [String: Any] {
        var b = JsonMapBuilder()

        b.put(JsonKeys.appVersion, appStatus.appVersion)
        b.put(JsonKeys.isLoggedIn, appStatus.isLoggedIn)

        if let userInfo = appStatus.userInfo {
            b.putAll(UserInfoMapper.toMap(userInfo))
        }

        return b.build()
    }
}
