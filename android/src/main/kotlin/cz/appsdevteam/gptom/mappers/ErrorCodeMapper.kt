package cz.appsdevteam.gptom.mappers

import cn.nexgo.smartconnect.model.ErrorResultEntity
import cn.nexgo.smartconnect.model.ErrorResultV2Entity
import cz.appsdevteam.gptom.models.ResultCodes

/**
 * Maps AAR error entity / resultCode to a plugin [ResultCodes] string.
 * Mirror of iOS `ResultCodes.from(DeeplinkError)`.
 *
 * Numeric V2 codes table: https://www.gptom.com/docs/api/app2app/result-codes/
 */
object ErrorCodeMapper {

    /**
     * For register-style errors (ErrorResultEntity with exception/errorCode strings)
     * and ECR resultCode int.
     */
    fun classify(error: ErrorResultEntity?, resultCode: Int? = null): String {
        val exception = error?.exception ?: ""

        when {
            exception.contains("UserLoggedOutException") -> return ResultCodes.INVALID_CREDENTIALS
            exception.contains("AuthenticationException") -> return ResultCodes.INVALID_CREDENTIALS
            exception.contains("InvalidCredentialsException") -> return ResultCodes.INVALID_CREDENTIALS
            exception.contains("MerchantInfoMissing") -> return ResultCodes.MERCHANT_INFO_MISSING
            exception.contains("InvalidClientId") -> return ResultCodes.INVALID_CLIENT_ID
            exception.contains("NetworkException")
                || exception.contains("SocketTimeout")
                || exception.contains("UnknownHost")
                || exception.contains("ConnectException") -> return ResultCodes.NETWORK_ERROR
            exception.contains("TimeoutException") -> return ResultCodes.TIMEOUT
            exception.contains("InvalidParameter")
                || exception.contains("IllegalArgument") -> return ResultCodes.INVALID_ARGUMENT
        }

        return when (resultCode) {
            0 -> ResultCodes.OK
            -2 -> ResultCodes.INVALID_ARGUMENT
            -4 -> ResultCodes.FAILED
            -5 -> ResultCodes.CANNOT_BE_VOIDED
            -6 -> ResultCodes.INVALID_ARGUMENT
            -7 -> ResultCodes.INVALID_CREDENTIALS
            -8 -> ResultCodes.UNSUPPORTED_TRANSACTION_OPERATION_OR_TYPE
            else -> ResultCodes.FAILED
        }
    }

    /**
     * For state-poll / batch errors (ErrorResultV2Entity with numeric error.code).
     */
    fun classifyV2(error: ErrorResultV2Entity?): String {
        return when (error?.code) {
            null -> ResultCodes.FAILED

            // Auth / credentials
            4, 40, 54 -> ResultCodes.INVALID_CREDENTIALS               // USER_LOGOUT, LOGIN_REQUIRED, NETWORK_UNAUTHORIZED
            49, 56, 57 -> ResultCodes.INVALID_CREDENTIALS              // CREDENTIALS_INVALID, NEW/OLD_PASS_INVALID
            31 -> ResultCodes.PASSWORD_CHANGE_REQUIRED                 // PASS_CHANGE_REQUIRED
            58, 60 -> ResultCodes.INVALID_CODE                         // NETWORK_AUTH_CODE_INVALID/EXPIRED

            // Client / merchant
            8 -> ResultCodes.INVALID_CLIENT_ID                         // INVALID_CLIENT

            // TID
            50, 51, 52 -> ResultCodes.TID_NOT_ASSIGNED_TO_THIS_USER    // TID_NOT_ACTIVE / EMPTY / NOT_SELECTED
            53, 61 -> ResultCodes.TID_ALREADY_OCCUPIED                 // TID_ALREADY_RESERVED, NETWORK_TID_ALREADY_RESERVED

            // Payment outcomes
            42 -> ResultCodes.FAILED                                   // PAYMENT_DECLINED
            43, 87, 96 -> ResultCodes.CANCELLED                        // PIN_TIMEOUT/CANCELLED, NEXGO_CANCELLED, APP2APP_CANCELLED
            44 -> ResultCodes.CANNOT_BE_VOIDED                         // PAYMENT_ALREADY_CANCELLED
            45 -> ResultCodes.FAILED                                   // PAYMENT_CANCELLATION_EXPIRED
            38 -> ResultCodes.CANNOT_BE_VOIDED                         // TRANSACTION_ALREADY_COMPLETED
            47, 88 -> ResultCodes.UNSUPPORTED_TRANSACTION_OPERATION_OR_TYPE // TRANSACTION_NOT_ALLOWED, NEXGO_NOT_SUPPORTED

            // Batch
            48 -> ResultCodes.FAILED_TO_CLOSE_BATCH                    // BATCH_DECLINED

            // Network
            62, 63, 64 -> ResultCodes.NETWORK_ERROR                    // NETWORK_UNAVAILABLE/HTTP/ERROR
            65 -> ResultCodes.TIMEOUT                                  // TRANSACTION_TIMEOUT

            // Tap-to-pay / SoftPOS
            66, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86 ->
                ResultCodes.FAILED_TAP_TO_PAY

            // Installation
            89 -> ResultCodes.NOT_INSTALLED                            // NEXGO_APP_MISSING

            // Invalid request
            55, 91, 97, 98 -> ResultCodes.INVALID_ARGUMENT             // WRONG_PARAMETER, NEXGO_INVALID, APP2APP_INVALID/ID_INVALID

            else -> ResultCodes.FAILED
        }
    }
}
