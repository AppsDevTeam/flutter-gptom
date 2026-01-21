// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:gptom/utils/json_keys.dart';
import 'package:gptom/utils/json_utils.dart';

enum GpTomErrorPlatform { tomApp, ams, external }

class GpTomErrorResult {
  final int errorCode;
  final String supportId;
  final String exception;

  GpTomErrorResult({required this.errorCode, required this.supportId, required this.exception});

  factory GpTomErrorResult.fromJson(Map<String, dynamic> json) {
    return GpTomErrorResult(
      errorCode: JsonUtils.asRequiredInt(json[JsonKeys.errorCode]),
      supportId: json[JsonKeys.supportId] as String? ?? '',
      exception: json[JsonKeys.exception] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {JsonKeys.errorCode: errorCode, JsonKeys.supportId: supportId, JsonKeys.exception: exception};
  }
}

class GpTomErrorResultV2 {
  final GpTomErrorPlatform? platform;
  final int? code;
  final int? internalErrorCode;
  final int? internalErrorSubCode;
  final GpTomErrorResult? cause;

  GpTomErrorResultV2({
    required this.platform,
    required this.code,
    required this.internalErrorCode,
    required this.internalErrorSubCode,
    required this.cause,
  });

  factory GpTomErrorResultV2.fromJson(Map<String, dynamic> json) {
    final causeMap = JsonUtils.asMap(json[JsonKeys.cause]);

    return GpTomErrorResultV2(
      platform: JsonUtils.enumFromName(json[JsonKeys.platform], GpTomErrorPlatform.values),
      code: JsonUtils.asInt(json[JsonKeys.code]),
      internalErrorCode: JsonUtils.asInt(json[JsonKeys.internalErrorCode]),
      internalErrorSubCode: JsonUtils.asInt(json[JsonKeys.internalErrorSubCode]),
      cause: causeMap == null ? null : GpTomErrorResult.fromJson(causeMap),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      JsonKeys.platform: platform?.name,
      JsonKeys.code: code,
      JsonKeys.internalErrorCode: internalErrorCode,
      JsonKeys.internalErrorSubCode: internalErrorSubCode,
      JsonKeys.cause: cause?.toJson(),
    };
  }
}
