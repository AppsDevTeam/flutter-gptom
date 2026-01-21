import 'dart:convert';

import 'package:gptom/utils/json_keys.dart';
import 'package:gptom/utils/json_utils.dart';
import 'package:meta/meta.dart';

@immutable
class GpTomPendingRequest {
  /// Android: transactionId, iOS: requestID.
  final String transactionId;

  final String? originReferenceNum;

  /// iOS: amsID (if known at the time).
  final String? amsId;

  /// Unix millis when created.
  final int createdAtMs;

  const GpTomPendingRequest({
    required this.transactionId,
    this.originReferenceNum,
    this.amsId,
    required this.createdAtMs,
  });

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, dynamic> toJson() => {
    JsonKeys.transactionId: transactionId,
    JsonKeys.originReferenceNum: originReferenceNum,
    JsonKeys.amsId: amsId,
    JsonKeys.createdAtMs: createdAtMs,
  };

  factory GpTomPendingRequest.fromJson(Map<String, dynamic> json) => GpTomPendingRequest(
    transactionId: JsonUtils.asString(json[JsonKeys.transactionId]) ?? '',
    originReferenceNum: JsonUtils.asString(json[JsonKeys.originReferenceNum]),
    amsId: JsonUtils.asString(json[JsonKeys.amsId]),
    createdAtMs: JsonUtils.asInt(json[JsonKeys.createdAtMs]) ?? 0,
  );
}
