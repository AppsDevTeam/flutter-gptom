import 'package:gptom/models/enums/result_codes.dart';
import 'package:gptom/utils/json_keys.dart';
import 'package:gptom/utils/json_utils.dart';

class GpTomResult<T> {
  final GpTomResultCode code;
  final String? message;
  final T? data;

  const GpTomResult({required this.code, this.message, this.data});

  bool get isOk => code == GpTomResultCode.ok;

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
      data: dataParser != null && dataJson != null ? dataParser(dataJson) : dataJson as T?,
    );
  }
}
