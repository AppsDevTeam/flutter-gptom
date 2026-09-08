import 'package:gptom/utils/json_keys.dart';
import 'package:gptom/utils/json_utils.dart';

enum GpTomLogLevel { debug, info, warning, error, unknown }

/// One log line produced by the native plugin.
///
/// Mirrored to Dart so a release build can record the plugin's own diagnostics
/// somewhere the device can show them - logcat and os_log are out of reach on a
/// till standing at a customer's counter. Lines are only produced while
/// `GpTomInitOptions.debugLogs` is on.
class GpTomLogEntry {
  final GpTomLogLevel level;
  final String message;

  /// Structured payload the plugin attached to the line, already flattened to
  /// its string form on the native side.
  final String? data;

  final DateTime? createdAt;

  const GpTomLogEntry({required this.level, required this.message, this.data, this.createdAt});

  factory GpTomLogEntry.fromJson(Map<String, dynamic> json) {
    final int? createdAtMs = JsonUtils.asInt(json[JsonKeys.createdAtMs]);

    return GpTomLogEntry(
      level: JsonUtils.enumFromNameRequired(json[JsonKeys.level], GpTomLogLevel.values, fallback: GpTomLogLevel.unknown),
      message: JsonUtils.asString(json[JsonKeys.message]) ?? '',
      data: JsonUtils.asString(json[JsonKeys.data]),
      createdAt: createdAtMs == null ? null : DateTime.fromMillisecondsSinceEpoch(createdAtMs),
    );
  }

  @override
  String toString() => data == null ? '[${level.name}] $message' : '[${level.name}] $message | data=$data';
}
