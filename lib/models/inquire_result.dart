import 'dart:convert';

import 'package:gptom/models/enums/card_holder_verification_method.dart';
import 'package:gptom/models/enums/card_product.dart';
import 'package:gptom/models/merchant_info.dart';
import 'package:gptom/utils/json_keys.dart';
import 'package:gptom/utils/json_utils.dart';

class GpTomInquireResult {
  final int result;
  final String? responseMessage;
  final String? trasanctionID;
  final String? externalTransactionID;
  final int? transacitonType;

  final String? merchantID;
  final String? terminalID;
  final String? currencyCode;

  final String? amount;
  final String? tipAmount;
  final String? cashbackAmount;

  final GpTomCardProduct? cardProduct;
  final String? cardNumber;
  final String? cardIssuer;
  final String? cardDataEntry;

  final String? approvedCode;
  final String? referenceNumber;
  final String? traceNumber;
  final String? invoiceNumber;

  final String? date;

  final String? emvAid;
  final String? emvAppLable;

  final String? sequenceNumber;
  final String? batchNumber;

  final String? receiptNumber;
  final bool? pinOk;
  final GpTomMerchantInfo? merchantInfo;
  final GpTomCardHolderVerificationMethod? cardHolderVerificationMethod;
  final String? blikCode;

  const GpTomInquireResult({
    required this.result,
    required this.responseMessage,
    required this.trasanctionID,
    required this.externalTransactionID,
    required this.transacitonType,
    required this.merchantID,
    required this.terminalID,
    required this.currencyCode,
    required this.amount,
    required this.tipAmount,
    required this.cashbackAmount,
    required this.cardProduct,
    required this.cardNumber,
    required this.cardIssuer,
    required this.cardDataEntry,
    required this.approvedCode,
    required this.referenceNumber,
    required this.traceNumber,
    required this.invoiceNumber,
    required this.date,
    required this.emvAid,
    required this.emvAppLable,
    required this.sequenceNumber,
    required this.batchNumber,
    required this.receiptNumber,
    required this.pinOk,
    required this.blikCode,
    required this.merchantInfo,
    required this.cardHolderVerificationMethod,
  });

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory GpTomInquireResult.fromJson(Map<String, dynamic> json) {
    final merchantInfoMap = JsonUtils.asMap(json[JsonKeys.merchantInfo]);

    return GpTomInquireResult(
      result: JsonUtils.asRequiredInt(json[JsonKeys.result], fallback: -1),
      responseMessage: JsonUtils.asString(json[JsonKeys.responseMessage]),
      trasanctionID: JsonUtils.asString(json[JsonKeys.transactionId]),
      externalTransactionID: JsonUtils.asString(json[JsonKeys.externalTransactionId]),
      transacitonType: JsonUtils.asInt(json[JsonKeys.transactionType]),
      merchantID: JsonUtils.asString(json[JsonKeys.merchantId]),
      terminalID: JsonUtils.asString(json[JsonKeys.terminalId]),
      currencyCode: JsonUtils.asString(json[JsonKeys.currencyCode]),
      amount: JsonUtils.asString(json[JsonKeys.amount]),
      tipAmount: JsonUtils.asString(json[JsonKeys.tipAmount]),
      cashbackAmount: JsonUtils.asString(json[JsonKeys.cashbackAmount]),
      cardProduct: GpTomCardProduct.fromJson(json[JsonKeys.cardProduct]),
      cardNumber: JsonUtils.asString(json[JsonKeys.cardNumber]),
      cardIssuer: JsonUtils.asString(json[JsonKeys.cardIssuer]),
      cardDataEntry: JsonUtils.asString(json[JsonKeys.cardDataEntry]),
      approvedCode: JsonUtils.asString(json[JsonKeys.approvedCode]),
      referenceNumber: JsonUtils.asString(json[JsonKeys.referenceNumber]),
      traceNumber: JsonUtils.asString(json[JsonKeys.traceNumber]),
      invoiceNumber: JsonUtils.asString(json[JsonKeys.invoiceNumber]),
      date: JsonUtils.asString(json[JsonKeys.date]),
      emvAid: JsonUtils.asString(json[JsonKeys.emvAid]),
      emvAppLable: JsonUtils.asString(json[JsonKeys.emvAppLable]),
      sequenceNumber: JsonUtils.asString(json[JsonKeys.sequenceNumber]),
      batchNumber: JsonUtils.asString(json[JsonKeys.batchNumber]),
      receiptNumber: JsonUtils.asString(json[JsonKeys.receiptNumber]),
      pinOk: JsonUtils.asBool(json[JsonKeys.pinOk]),
      blikCode: JsonUtils.asString(json[JsonKeys.blikCode]),
      merchantInfo: merchantInfoMap == null ? null : GpTomMerchantInfo.fromJson(merchantInfoMap),
      cardHolderVerificationMethod: GpTomCardHolderVerificationMethod.fromJson(
        json[JsonKeys.cardHolderVerificationMethod],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    JsonKeys.result: result,
    JsonKeys.responseMessage: responseMessage,
    JsonKeys.transactionId: trasanctionID,
    JsonKeys.externalTransactionId: externalTransactionID,
    JsonKeys.transactionType: transacitonType,
    JsonKeys.merchantId: merchantID,
    JsonKeys.terminalId: terminalID,
    JsonKeys.currencyCode: currencyCode,
    JsonKeys.amount: amount,
    JsonKeys.tipAmount: tipAmount,
    JsonKeys.cashbackAmount: cashbackAmount,
    JsonKeys.cardProduct: cardProduct?.toJson(),
    JsonKeys.cardNumber: cardNumber,
    JsonKeys.cardIssuer: cardIssuer,
    JsonKeys.cardDataEntry: cardDataEntry,
    JsonKeys.approvedCode: approvedCode,
    JsonKeys.referenceNumber: referenceNumber,
    JsonKeys.traceNumber: traceNumber,
    JsonKeys.invoiceNumber: invoiceNumber,
    JsonKeys.date: date,
    JsonKeys.emvAid: emvAid,
    JsonKeys.emvAppLable: emvAppLable,
    JsonKeys.sequenceNumber: sequenceNumber,
    JsonKeys.batchNumber: batchNumber,
    JsonKeys.receiptNumber: receiptNumber,
    JsonKeys.pinOk: pinOk,
    JsonKeys.blikCode: blikCode,
    JsonKeys.merchantInfo: merchantInfo?.toJson(),
    JsonKeys.cardHolderVerificationMethod: cardHolderVerificationMethod?.toJson(),
  };
}
