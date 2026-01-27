package cz.appsdevteam.gptom.models

object ResultCodes {
    const val OK = "ok"
    const val NOT_INITIALIZED = "notInitialized"
    const val NOT_INSTALLED = "notInstalled"
    const val UNSUPPORTED_ON_PLATFORM = "unsupportedOnPlatform"
    const val INVALID_ARGUMENT = "invalidArgument"
    const val TIMEOUT = "timeout"
    const val SERVICE_BIND_FAILED = "serviceBindFailed"
    const val INTERNAL_ERROR = "internalError"
    const val FAILED = "failed"
    const val NETWORK_ERROR = "networkError"
    const val INVALID_CLIENT_ID = "invalidClientId"
    const val MERCHANT_INFO_MISSING = "merchantInfoMissing"
    const val FAILED_TAP_TO_PAY = "failedTapToPay"
    const val FAILED_TO_CLOSE_BATCH = "failedToCloseBatch"
    const val INVALID_DEEPLINK = "invalidDeeplink"
}
