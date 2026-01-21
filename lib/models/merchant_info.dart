import 'dart:convert';

import 'package:gptom/utils/json_keys.dart';
import 'package:gptom/utils/json_utils.dart';

class GpTomMerchantInfo {
  final String? company;
  final String? city;
  final String? street;
  final String? house;
  final String? location;
  final String? country;
  final String? zip;

  const GpTomMerchantInfo({
    required this.company,
    required this.city,
    required this.street,
    required this.house,
    required this.location,
    required this.country,
    required this.zip,
  });

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory GpTomMerchantInfo.fromJson(Map<String, dynamic> json) {
    return GpTomMerchantInfo(
      company: JsonUtils.asString(json[JsonKeys.company]),
      city: JsonUtils.asString(json[JsonKeys.city]),
      street: JsonUtils.asString(json[JsonKeys.street]),
      house: JsonUtils.asString(json[JsonKeys.house]),
      location: JsonUtils.asString(json[JsonKeys.location]),
      country: JsonUtils.asString(json[JsonKeys.country]),
      zip: JsonUtils.asString(json[JsonKeys.zip]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      JsonKeys.company: company,
      JsonKeys.city: city,
      JsonKeys.street: street,
      JsonKeys.house: house,
      JsonKeys.location: location,
      JsonKeys.country: country,
      JsonKeys.zip: zip,
    };
  }
}
