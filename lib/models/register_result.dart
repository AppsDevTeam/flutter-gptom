import 'dart:convert';

import 'package:gptom/models/error_result.dart';
import 'package:gptom/utils/json_keys.dart';
import 'package:gptom/utils/json_utils.dart';

class GpTomRegisterResult {
  final int resultCode;
  final String? transactionId;
  final String? clientId;
  final String? responseMessage;
  final GpTomErrorResult? error;
  final String? originReferenceNum;

  const GpTomRegisterResult({
    required this.resultCode,
    this.transactionId,
    this.clientId,
    this.responseMessage,
    this.error,
    this.originReferenceNum,
  });

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory GpTomRegisterResult.fromJson(Map<String, dynamic> json) {
    final errorMap = JsonUtils.asMap(json[JsonKeys.error]);

    return GpTomRegisterResult(
      resultCode: JsonUtils.asRequiredInt(json[JsonKeys.resultCode], fallback: -1),
      transactionId: JsonUtils.asString(json[JsonKeys.transactionId]),
      clientId: JsonUtils.asString(json[JsonKeys.clientId]),
      responseMessage: JsonUtils.asString(json[JsonKeys.responseMessage]),
      error: errorMap == null ? null : GpTomErrorResult.fromJson(errorMap),
      originReferenceNum: JsonUtils.asString(json[JsonKeys.originReferenceNum]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      JsonKeys.resultCode: resultCode,
      JsonKeys.transactionId: transactionId,
      JsonKeys.clientId: clientId,
      JsonKeys.responseMessage: responseMessage,
      JsonKeys.error: error?.toJson(),
      JsonKeys.originReferenceNum: originReferenceNum,
    };
  }
}
