import 'dart:convert';

import 'package:gptom/models/enums/transaction_state.dart';
import 'package:gptom/models/error_result.dart';
import 'package:gptom/utils/json_keys.dart';
import 'package:gptom/utils/json_utils.dart';

class GpTomStateResult {
  /// result API
  final int resultCode;

  /// request ID
  final String? transactionId;

  /// request status
  final GpTomTransactionState state;

  /// Can be request repeated?
  final bool? isRepeatable;

  /// Request creation date
  final DateTime? created;

  /// The date the request status changed
  final DateTime? updated;

  final GpTomErrorResult? cause;

  GpTomStateResult({
    required this.resultCode,
    required this.transactionId,
    required this.state,
    required this.isRepeatable,
    required this.created,
    required this.updated,
    required this.cause,
  });

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory GpTomStateResult.fromJson(Map<String, dynamic> json) {
    final causeMap = JsonUtils.asMap(json[JsonKeys.cause]);

    return GpTomStateResult(
      resultCode: JsonUtils.asRequiredInt(json[JsonKeys.resultCode], fallback: -1),
      transactionId: JsonUtils.asString(json[JsonKeys.transactionId]),
      state: GpTomTransactionState.fromValue(JsonUtils.asInt(json[JsonKeys.state])),
      isRepeatable: JsonUtils.asBool(json[JsonKeys.isRepeatable]),
      created: JsonUtils.asDateTime(json[JsonKeys.created]),
      updated: JsonUtils.asDateTime(json[JsonKeys.updated]),
      cause: causeMap == null ? null : GpTomErrorResult.fromJson(causeMap),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      JsonKeys.resultCode: resultCode,
      JsonKeys.transactionId: transactionId,
      JsonKeys.state: state.value,
      JsonKeys.isRepeatable: isRepeatable,
      JsonKeys.created: created?.toIso8601String(),
      JsonKeys.updated: updated?.toIso8601String(),
      JsonKeys.cause: cause?.toJson(),
    };
  }
}
