import 'package:gptom/utils/json_utils.dart';

enum GpTomCardHolderVerificationMethod {
  pin,
  passcode,
  signature,
  none;

  static GpTomCardHolderVerificationMethod? fromJson(String? json) {
    if (json != null) {
      final normalized = json.trim().toLowerCase().replaceAll('_', '');

      return JsonUtils.enumFromName(normalized, values);
    }

    return null;
  }

  String toJson() => name.toUpperCase();
}
