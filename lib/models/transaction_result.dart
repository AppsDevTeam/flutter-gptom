import 'dart:convert';

import 'package:gptom/models/card_holder_verification_method.dart';
import 'package:gptom/models/card_product.dart';
import 'package:gptom/models/error_result.dart';
import 'package:gptom/models/merchant_info.dart';
import 'package:gptom/utils/json_keys.dart';
import 'package:gptom/utils/json_utils.dart';
import 'package:meta/meta.dart';

/// Result of a started transaction/cancel/refund call.
///
/// - Android: `transactionId` is the ID returned by register (and used for state/inquire).
/// - iOS: `transactionId` is the internally generated requestID (for correlation/recovery).
@immutable
class GpTomTransactionResult {
  final int result;
  final GpTomErrorResult? error;
  final String? clientId;
  final String? responseMessage;
  final String? transactionId;
  final String? asmId;
  final String? externalTransactionId;
  final int? transactionType;
  final String? merchantId;
  final String? terminalId;
  final int? currencyCode;
  final int? amount;
  final int? tipAmount;
  final int? cashbackAmount;

  final String? cardNumber;
  final String? cardIssuer;
  final String? cardDataEntry;

  final String? approvedCode;
  final String? referenceNumber;
  final String? invoiceNumber;

  final String? date;
  final String? time;

  final String? emvAId;
  final String? emvAppLabel;

  final String? sequenceNumber;
  final String? batchNumber;

  final int? batchTotalNum;
  final int? batchTotalAmount;
  final int? batchSaleNum;
  final int? batchSaleAmount;
  final int? batchVoidNum;
  final int? batchVoidAmount;

  final bool? printByPaymentApp;
  final GpTomCardProduct? cardProduct;
  final String? receiptNumber;
  final bool? pinOk;

  final GpTomMerchantInfo? merchantInfo;
  final GpTomCardHolderVerificationMethod? cardHolderVerificationMethod;

  final String? blikCode;

  const GpTomTransactionResult({
    required this.result,
    required this.error,
    required this.clientId,
    required this.responseMessage,
    required this.transactionId,
    required this.asmId,
    required this.externalTransactionId,
    required this.transactionType,
    required this.merchantId,
    required this.terminalId,
    required this.currencyCode,
    required this.amount,
    required this.tipAmount,
    required this.cashbackAmount,
    required this.cardNumber,
    required this.cardIssuer,
    required this.cardDataEntry,
    required this.approvedCode,
    required this.referenceNumber,
    required this.invoiceNumber,
    required this.date,
    required this.time,
    required this.emvAId,
    required this.emvAppLabel,
    required this.sequenceNumber,
    required this.batchNumber,
    required this.batchTotalNum,
    required this.batchTotalAmount,
    required this.batchSaleNum,
    required this.batchSaleAmount,
    required this.batchVoidNum,
    required this.batchVoidAmount,
    required this.printByPaymentApp,
    required this.cardProduct,
    required this.receiptNumber,
    required this.pinOk,
    required this.merchantInfo,
    required this.cardHolderVerificationMethod,
    required this.blikCode,
  });

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory GpTomTransactionResult.fromJson(Map<String, dynamic> json) {
    final errorMap = JsonUtils.asMap(json[JsonKeys.error]);
    final merchantInfoMap = JsonUtils.asMap(json[JsonKeys.merchantInfo]);

    return GpTomTransactionResult(
      result: JsonUtils.asRequiredInt(json[JsonKeys.result], fallback: -1),
      error: errorMap == null ? null : GpTomErrorResult.fromJson(errorMap),
      clientId: JsonUtils.asString(json[JsonKeys.clientId]),
      responseMessage: JsonUtils.asString(json[JsonKeys.responseMessage]),
      transactionId: JsonUtils.asString(json[JsonKeys.transactionId]),
      asmId: JsonUtils.asString(json[JsonKeys.amsId]),
      externalTransactionId: JsonUtils.asString(json[JsonKeys.externalTransactionId]),
      transactionType: JsonUtils.asInt(json[JsonKeys.transactionType]),
      merchantId: JsonUtils.asString(json[JsonKeys.merchantId]),
      terminalId: JsonUtils.asString(json[JsonKeys.terminalId]),
      currencyCode: JsonUtils.asInt(json[JsonKeys.currencyCode]),
      amount: JsonUtils.asInt(json[JsonKeys.amount]),
      tipAmount: JsonUtils.asInt(json[JsonKeys.tipAmount]),
      cashbackAmount: JsonUtils.asInt(json[JsonKeys.cashbackAmount]),
      cardNumber: JsonUtils.asString(json[JsonKeys.cardNumber]),
      cardIssuer: JsonUtils.asString(json[JsonKeys.cardIssuer]),
      cardDataEntry: JsonUtils.asString(json[JsonKeys.cardDataEntry]),
      approvedCode: JsonUtils.asString(json[JsonKeys.approvedCode]),
      referenceNumber: JsonUtils.asString(json[JsonKeys.referenceNumber]),
      invoiceNumber: JsonUtils.asString(json[JsonKeys.invoiceNumber]),
      date: JsonUtils.asString(json[JsonKeys.date]),
      time: JsonUtils.asString(json[JsonKeys.time]),
      emvAId: JsonUtils.asString(json[JsonKeys.emvAid]),
      emvAppLabel: JsonUtils.asString(json[JsonKeys.emvAppLabel]),
      sequenceNumber: JsonUtils.asString(json[JsonKeys.sequenceNumber]),
      batchNumber: JsonUtils.asString(json[JsonKeys.batchNumber]),
      batchTotalNum: JsonUtils.asInt(json[JsonKeys.batchTotalNum]),
      batchTotalAmount: JsonUtils.asInt(json[JsonKeys.batchTotalAmount]),
      batchSaleNum: JsonUtils.asInt(json[JsonKeys.batchSaleNum]),
      batchSaleAmount: JsonUtils.asInt(json[JsonKeys.batchSaleAmount]),
      batchVoidNum: JsonUtils.asInt(json[JsonKeys.batchVoidNum]),
      batchVoidAmount: JsonUtils.asInt(json[JsonKeys.batchVoidAmount]),
      printByPaymentApp: JsonUtils.asBool(json[JsonKeys.printByPaymentApp]),
      cardProduct: GpTomCardProduct.fromJson(json[JsonKeys.cardProduct]),
      receiptNumber: JsonUtils.asString(json[JsonKeys.receiptNumber]),
      pinOk: JsonUtils.asBool(json[JsonKeys.pinOk]),
      merchantInfo: merchantInfoMap == null ? null : GpTomMerchantInfo.fromJson(merchantInfoMap),
      cardHolderVerificationMethod: GpTomCardHolderVerificationMethod.fromJson(
        json[JsonKeys.cardHolderVerificationMethod],
      ),
      blikCode: JsonUtils.asString(json[JsonKeys.blikCode]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      JsonKeys.result: result,
      JsonKeys.error: error?.toJson(),
      JsonKeys.clientId: clientId,
      JsonKeys.responseMessage: responseMessage,
      JsonKeys.transactionId: transactionId,
      JsonKeys.amsId: asmId,
      JsonKeys.externalTransactionId: externalTransactionId,
      JsonKeys.transactionType: transactionType,
      JsonKeys.merchantId: merchantId,
      JsonKeys.terminalId: terminalId,
      JsonKeys.currencyCode: currencyCode,
      JsonKeys.amount: amount,
      JsonKeys.tipAmount: tipAmount,
      JsonKeys.cashbackAmount: cashbackAmount,
      JsonKeys.cardNumber: cardNumber,
      JsonKeys.cardIssuer: cardIssuer,
      JsonKeys.cardDataEntry: cardDataEntry,
      JsonKeys.approvedCode: approvedCode,
      JsonKeys.referenceNumber: referenceNumber,
      JsonKeys.invoiceNumber: invoiceNumber,
      JsonKeys.date: date,
      JsonKeys.time: time,
      JsonKeys.emvAid: emvAId,
      JsonKeys.emvAppLabel: emvAppLabel,
      JsonKeys.sequenceNumber: sequenceNumber,
      JsonKeys.batchNumber: batchNumber,
      JsonKeys.batchTotalNum: batchTotalNum,
      JsonKeys.batchTotalAmount: batchTotalAmount,
      JsonKeys.batchSaleNum: batchSaleNum,
      JsonKeys.batchSaleAmount: batchSaleAmount,
      JsonKeys.batchVoidNum: batchVoidNum,
      JsonKeys.batchVoidAmount: batchVoidAmount,
      JsonKeys.printByPaymentApp: printByPaymentApp,
      JsonKeys.cardProduct: cardProduct?.toJson(),
      JsonKeys.receiptNumber: receiptNumber,
      JsonKeys.pinOk: pinOk,
      JsonKeys.merchantInfo: merchantInfo?.toJson(),
      JsonKeys.cardHolderVerificationMethod: cardHolderVerificationMethod?.toJson(),
      JsonKeys.blikCode: blikCode,
    };
  }
}
