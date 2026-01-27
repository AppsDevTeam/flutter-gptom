package cz.appsdevteam.gptom.models

enum class TransactionType(val code: Int, val kind: String) {
    SALE(1, "sale"),
    CANCEL(2, "cancel"),
    REFUND(3, "refund"),
    CLOSE_BATCH(4, "closeBatch");

    companion object {
        fun fromInt(code: Int?): TransactionType? = entries.find { it.code == code }
    }
}