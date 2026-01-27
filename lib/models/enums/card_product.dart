import 'package:gptom/utils/json_utils.dart';

enum GpTomCardProduct {
  unknow,
  visa,
  master,
  mastercard,
  cup,
  jcb,
  amex,
  discovery,
  discover,
  maestro,
  none,
  jcbandvisa,
  troy,
  unionpay,
  rupay,
  pure,
  girocard;

  static GpTomCardProduct? fromJson(String? json) {
    if (json != null) {
      final normalized = json.trim().toLowerCase().replaceAll('_', '');

      return JsonUtils.enumFromNameRequired(normalized, values, fallback: GpTomCardProduct.unknow);
    }

    return null;
  }

  String toJson() => name.toUpperCase();
}
