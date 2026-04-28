import 'dart:convert';

import 'package:gptom/models/enums/result_codes.dart';
import 'package:gptom/utils/json_keys.dart';
import 'package:gptom/utils/json_utils.dart';

class GpTomResult<T> {
  final GpTomResultCode code;
  final String? message;
  final String? transactionId;
  final T? data;

  const GpTomResult({required this.code, this.message, this.transactionId, this.data});

  bool get isOk => code == GpTomResultCode.ok;

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toJson());

  static GpTomResult<T> fromMap<T>(Map<Object?, Object?> map, {T Function(Object?)? dataParser}) {
    final json = map.map((k, v) => MapEntry(k?.toString() ?? '', v));
    final dataJson = json[JsonKeys.data];

    final code = JsonUtils.enumFromNameRequired(
      json[JsonKeys.code],
      GpTomResultCode.values,
      fallback: GpTomResultCode.internalError,
    );

    return GpTomResult<T>(
      code: code,
      message: JsonUtils.asString(json[JsonKeys.message]),
      transactionId: JsonUtils.asString(json[JsonKeys.transactionId]),
      data: dataParser != null && dataJson != null ? dataParser(dataJson) : dataJson as T?,
    );
  }

  Map<String, dynamic> toJson() => {
    JsonKeys.code: code.name,
    JsonKeys.message: message,
    JsonKeys.transactionId: transactionId,
    JsonKeys.data: _dataToJson(data),
  };

  static Object? _dataToJson(Object? data) {
    if (data == null) return null;

    if (data is num || data is String || data is bool || data is Map || data is List) return data;

    try {
      return (data as dynamic).toJson();
    } catch (_) {
      return data.toString();
    }
  }
}
