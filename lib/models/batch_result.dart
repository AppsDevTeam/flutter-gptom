import 'dart:convert';

import 'package:gptom/utils/json_keys.dart';
import 'package:gptom/utils/json_utils.dart';
import 'package:meta/meta.dart';

@immutable
class GpTomBatchResult {
  final String? transactionId;
  final String? asmId;
  final String? terminalId;

  final String? communicationId;
  final String? batchNumber;
  final String? currency;

  final String? date;
  final String? firstTransactionDate;

  final double? invalidCount;

  final String? previousBatchDate;

  final double? totalCount;
  final int? totalAmount;
  final double? saleCount;
  final int? saleAmount;
  final double? voidCount;
  final int? voidAmount;

  final int? tipAmount;
  final int? tipCount;

  final int? tipAverage;
  final double? tipAveragePercentage;

  const GpTomBatchResult({
    required this.transactionId,
    required this.asmId,
    required this.terminalId,
    required this.communicationId,
    required this.batchNumber,
    required this.currency,
    required this.date,
    required this.firstTransactionDate,
    required this.invalidCount,
    required this.previousBatchDate,
    required this.totalCount,
    required this.totalAmount,
    required this.saleCount,
    required this.saleAmount,
    required this.voidCount,
    required this.voidAmount,
    required this.tipAmount,
    required this.tipCount,
    required this.tipAverage,
    required this.tipAveragePercentage,
  });

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory GpTomBatchResult.fromJson(Map<String, dynamic> json) {
    return GpTomBatchResult(
      transactionId: JsonUtils.asString(json[JsonKeys.transactionId]),
      asmId: JsonUtils.asString(json[JsonKeys.amsId]),
      terminalId: JsonUtils.asString(json[JsonKeys.terminalId]),
      communicationId: JsonUtils.asString(json[JsonKeys.communicationId]),
      batchNumber: JsonUtils.asString(json[JsonKeys.batchNumber]),
      currency: JsonUtils.asCurrencyCode(json[JsonKeys.currencyCode]),
      date: JsonUtils.asString(json[JsonKeys.date]),
      firstTransactionDate: JsonUtils.asString(json[JsonKeys.firstTransactionDate]),
      invalidCount: JsonUtils.asDouble(json[JsonKeys.invalidCount]),
      previousBatchDate: JsonUtils.asString(json[JsonKeys.previousBatchDate]),
      totalCount: JsonUtils.asDouble(json[JsonKeys.totalCount]),
      totalAmount: JsonUtils.asInt(json[JsonKeys.totalAmount]),
      saleCount: JsonUtils.asDouble(json[JsonKeys.saleCount]),
      saleAmount: JsonUtils.asInt(json[JsonKeys.saleAmount]),
      voidCount: JsonUtils.asDouble(json[JsonKeys.voidCount]),
      voidAmount: JsonUtils.asInt(json[JsonKeys.voidAmount]),
      tipAmount: JsonUtils.asInt(json[JsonKeys.tipAmount]),
      tipCount: JsonUtils.asInt(json[JsonKeys.tipCount]),
      tipAverage: JsonUtils.asInt(json[JsonKeys.tipAverage]),
      tipAveragePercentage: JsonUtils.asDouble(json[JsonKeys.tipAveragePercentage]),
    );
  }

  Map<String, dynamic> toJson() => {
    JsonKeys.transactionId: transactionId,
    JsonKeys.amsId: asmId,
    JsonKeys.terminalId: terminalId,
    JsonKeys.communicationId: communicationId,
    JsonKeys.batchNumber: batchNumber,
    JsonKeys.currencyCode: currency,
    JsonKeys.date: date,
    JsonKeys.firstTransactionDate: firstTransactionDate,
    JsonKeys.invalidCount: invalidCount,
    JsonKeys.previousBatchDate: previousBatchDate,
    JsonKeys.totalCount: totalCount,
    JsonKeys.totalAmount: totalAmount,
    JsonKeys.saleCount: saleCount,
    JsonKeys.saleAmount: saleAmount,
    JsonKeys.voidCount: voidCount,
    JsonKeys.voidAmount: voidAmount,
    JsonKeys.tipAmount: tipAmount,
    JsonKeys.tipCount: tipCount,
    JsonKeys.tipAverage: tipAverage,
    JsonKeys.tipAveragePercentage: tipAveragePercentage,
  };
}
