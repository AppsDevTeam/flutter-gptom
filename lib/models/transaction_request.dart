import 'package:gptom/utils/json_keys.dart';
import 'package:meta/meta.dart';

enum GpTomTransactionType {
  sale(1),
  storno(2),
  refund(3),
  closeBatch(4);

  const GpTomTransactionType(this.code);
  final int code;
}

enum GpTomPaymentMethod {
  card("CARD"),
  cash("CASH"),
  accountPayment("ACCOUNT_PAYMENT"),
  blikPayment("BLIK_PAYMENT"),
  paymentGateway("PAYMENT_GATEWAY"),
  goCrypto("GO_CRYPTO");

  const GpTomPaymentMethod(this.value);
  final String value;
}

enum GpTomCancelMode {
  lastTransaction(1),
  olderTransaction(2);

  const GpTomCancelMode(this.code);
  final int code;
}

@immutable
class GpTomTransactionRequest {
  final GpTomPaymentMethod? paymentMethod;

  /// If true, GP tom handles receipt sending. Default true.
  final bool printByPaymentApp;

  /// Amount in minor units (e.g. cents). Required for sale/refund.
  final int? amount;

  /// Tip amount in minor units (optional).
  final int? tipAmount;

  /// Optional client/terminal API key.
  final String? clientId;

  final String transactionId;

  /// Sale/refund/cancel.
  final GpTomTransactionType transactionType;

  /// Original transaction id / requestId / amsID to cancel or refund.
  final String? originTransactionId;

  /// Your reference up to 20 chars.
  final String? originReferenceNum;

  final GpTomCancelMode? cancelMode;

  /// Optional currency code (ISO 4217 numeric or alphabetic depending on platform).
  final String? currencyCode;

  /// If true, GP tom will ask user for tip in-app.
  final bool? tipCollect;

  const GpTomTransactionRequest({
    required this.transactionId,
    required this.transactionType,
    this.amount,
    this.originTransactionId,
    this.originReferenceNum,
    this.clientId,
    bool? printByPaymentApp,
    this.tipCollect = false,
    this.tipAmount,
    this.currencyCode,
    this.paymentMethod,
    this.cancelMode,
  }) : printByPaymentApp = printByPaymentApp ?? false;

  /// Convenience: sale.
  factory GpTomTransactionRequest.sale({
    required String transactionId,
    required int amount,
    String? originReferenceNum,
    String? clientId,
    bool? printByPaymentApp,
    bool tipCollect = false,
    int? tipAmount,
    String? currencyCode,
    GpTomPaymentMethod? paymentMethod,
  }) {
    return GpTomTransactionRequest(
      transactionId: transactionId,
      transactionType: GpTomTransactionType.sale,
      amount: amount,
      originReferenceNum: originReferenceNum,
      clientId: clientId,
      printByPaymentApp: printByPaymentApp,
      tipCollect: tipCollect,
      tipAmount: tipAmount,
      currencyCode: currencyCode,
      paymentMethod: paymentMethod,
    );
  }

  /// Convenience: storn.
  factory GpTomTransactionRequest.storno({
    required String transactionId,
    required GpTomCancelMode cancelMode,
    required String originTransactionId,
    String? clientId,
    GpTomPaymentMethod? paymentMethod,
  }) {
    return GpTomTransactionRequest(
      transactionId: transactionId,
      transactionType: GpTomTransactionType.storno,
      originTransactionId: originTransactionId,
      clientId: clientId,
      paymentMethod: paymentMethod,
      cancelMode: cancelMode,
    );
  }

  /// Convenience: refund.
  factory GpTomTransactionRequest.refund({
    required String transactionId,
    required int amount,
    String? originReferenceNum,
    String? clientId,
    GpTomPaymentMethod? paymentMethod,
  }) {
    return GpTomTransactionRequest(
      transactionId: transactionId,
      transactionType: GpTomTransactionType.refund,
      amount: amount,
      originReferenceNum: originReferenceNum,
      clientId: clientId,
      paymentMethod: paymentMethod,
    );
  }

  Map<String, dynamic> toJson() => {
    JsonKeys.paymentMethod: paymentMethod?.value,
    JsonKeys.printByPaymentApp: printByPaymentApp,
    JsonKeys.amount: amount,
    JsonKeys.tipAmount: tipAmount,
    JsonKeys.clientId: clientId,
    JsonKeys.transactionId: transactionId,
    JsonKeys.transactionType: transactionType.code,
    JsonKeys.originTransactionId: originTransactionId,
    JsonKeys.originReferenceNum: originReferenceNum,
    JsonKeys.cancelMode: cancelMode?.code,
    JsonKeys.currencyCode: currencyCode,
    JsonKeys.tipCollect: tipCollect,
  };
}
