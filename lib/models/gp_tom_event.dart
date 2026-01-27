import 'package:gptom/utils/json_keys.dart';
import 'package:gptom/utils/json_utils.dart';

enum GpTomEventKind { sale, refund, cancel, closeBatch, detail, state, appStatus, unknown }

class GpTomEvent {
  final GpTomEventKind kind;
  final String? transactionId;
  final Map<String, dynamic> fullMap;

  const GpTomEvent({required this.kind, this.transactionId, required this.fullMap});

  factory GpTomEvent.fromJson(Map<String, dynamic> json) => GpTomEvent(
    kind: JsonUtils.enumFromNameRequired(json[JsonKeys.kind], GpTomEventKind.values, fallback: GpTomEventKind.unknown),
    transactionId: JsonUtils.asString(json[JsonKeys.transactionId]),
    fullMap: json,
  );
}
