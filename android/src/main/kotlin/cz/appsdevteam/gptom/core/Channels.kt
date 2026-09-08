package cz.appsdevteam.gptom.core

object Channels {
    const val METHODS = "adt_gptom/methods"
    const val EVENTS = "adt_gptom/events"

    /** Plugin's own log lines, mirrored to Dart for on-device diagnostics. */
    const val LOGS = "adt_gptom/logs"
}
