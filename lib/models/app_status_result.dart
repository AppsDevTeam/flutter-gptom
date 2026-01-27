import 'dart:convert';

import 'package:gptom/models/user_address.dart';
import 'package:gptom/utils/json_keys.dart';
import 'package:gptom/utils/json_utils.dart';
import 'package:meta/meta.dart';

@immutable
class GpTomAppStatusResultResult {
  final String? appVersion;
  final bool isLoggedIn;
  final String? tid;
  final String? mid;
  final String? clientId;
  final String? businessId;
  final String? email;

  final double? vat;

  final bool? tipEnabled;
  final bool? printerAvailable;
  final bool? manualTransactionRestricted;
  final GpTomUserAddress? merchantLocationEntity;

  const GpTomAppStatusResultResult({
    required this.appVersion,
    required this.isLoggedIn,
    required this.tid,
    required this.mid,
    required this.clientId,
    required this.businessId,
    required this.email,
    required this.vat,
    required this.tipEnabled,
    required this.printerAvailable,
    required this.manualTransactionRestricted,
    required this.merchantLocationEntity,
  });

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory GpTomAppStatusResultResult.fromJson(Map<String, dynamic> json) {
    return GpTomAppStatusResultResult(
      appVersion: JsonUtils.asString(json[JsonKeys.appVersion]),
      isLoggedIn: JsonUtils.asRequiredBool(json[JsonKeys.isLoggedIn]),
      tid: JsonUtils.asString(json[JsonKeys.tid]),
      mid: JsonUtils.asString(json[JsonKeys.mid]),
      clientId: JsonUtils.asString(json[JsonKeys.clientId]),
      businessId: JsonUtils.asString(json[JsonKeys.businessId]),
      email: JsonUtils.asString(json[JsonKeys.email]),
      vat: JsonUtils.asDouble(json[JsonKeys.vat]),
      tipEnabled: JsonUtils.asBool(json[JsonKeys.tipEnabled]),
      printerAvailable: JsonUtils.asBool(json[JsonKeys.printerAvailable]),
      manualTransactionRestricted: JsonUtils.asBool(json[JsonKeys.manualTransactionRestricted]),
      merchantLocationEntity: json.containsKey(JsonKeys.merchantLocationEntity)
          ? GpTomUserAddress.fromJson(json[JsonKeys.merchantLocationEntity])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    JsonKeys.appVersion: appVersion,
    JsonKeys.isLoggedIn: isLoggedIn,
    JsonKeys.tid: tid,
    JsonKeys.mid: mid,
    JsonKeys.clientId: clientId,
    JsonKeys.businessId: businessId,
    JsonKeys.email: email,
    JsonKeys.vat: vat,
    JsonKeys.tipEnabled: tipEnabled,
    JsonKeys.printerAvailable: printerAvailable,
    JsonKeys.manualTransactionRestricted: manualTransactionRestricted,
    JsonKeys.merchantLocationEntity: merchantLocationEntity?.toJson(),
  };
}
