package cz.appsdevteam.gptom.support

import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

object DateUtils {
    private val isoFormatter = DateTimeFormatter.ISO_DATE_TIME

    fun toISO8601(dateStr: String?, timeStr: String?): String? {
        if (dateStr.isNullOrBlank() || timeStr.isNullOrBlank()) {
            return null
        }

        return try {
            val date = LocalDateTime.parse("$dateStr$timeStr", DateTimeFormatter.ofPattern("ddMMyyHHmmss"))
            date.format(isoFormatter)
        } catch (e: Exception) {
            null
        }
    }
}
