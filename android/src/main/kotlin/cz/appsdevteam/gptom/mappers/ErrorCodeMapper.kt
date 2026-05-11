package cz.appsdevteam.gptom.mappers

import cn.nexgo.smartconnect.model.ErrorResultEntity
import cz.appsdevteam.gptom.models.ResultCodes

/**
 * Maps AAR error entity / resultCode to a plugin [ResultCodes] string.
 * Mirror of iOS `ResultCodes.from(DeeplinkError)`.
 *
 * Resolution order:
 *  1. Exception class name match (specific Java/Kotlin exceptions from AAR)
 *  2. ECR result code (standardized, see https://www.gptom.com/docs/api/app2app/result-codes/)
 *  3. Fallback to FAILED
 */
object ErrorCodeMapper {

    fun classify(error: ErrorResultEntity?, resultCode: Int? = null): String {
        val exception = error?.exception ?: ""

        // 1. Specific exception class patterns
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

        // 2. ECR result codes (https://www.gptom.com/docs/api/app2app/result-codes/)
        return when (resultCode) {
            0 -> ResultCodes.OK
            -2 -> ResultCodes.INVALID_ARGUMENT             // ECR_TRANSACTIONID_INVALID
            -4 -> ResultCodes.FAILED                       // ECR_TRANSACTION_DECLINE
            -5 -> ResultCodes.CANNOT_BE_VOIDED             // ECR_TRANSACTION_ALREADY_VOIDED
            -6 -> ResultCodes.INVALID_ARGUMENT             // ECR_PARAMETER_INVALID
            -7 -> ResultCodes.INVALID_CREDENTIALS          // ECR_UNAUTHORIZED
            -8 -> ResultCodes.UNSUPPORTED_TRANSACTION_OPERATION_OR_TYPE // ECR_NOT_ALLOWED
            else -> ResultCodes.FAILED
        }
    }
}
