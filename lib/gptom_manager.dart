import 'dart:async';

import 'package:flutter/services.dart';
import 'package:gptom/gptom.dart';
import 'package:gptom/models/batch_result.dart';
import 'package:gptom/models/inquire_result.dart';
import 'package:gptom/utils/json_keys.dart';

class GpTomManager {
  static const MethodChannel _methodChannel = MethodChannel('adt_gptom/methods');
  static const EventChannel _eventsChannel = EventChannel('adt_gptom/events');

  static bool _initialized = false;

  /// Raw events (debug / low-level)
  static Stream<GpTomEvent>? _events;
  static Stream<GpTomEvent> get events {
    return _events ??= _eventsChannel.receiveBroadcastStream().map(
      (e) => GpTomEvent.fromJson(Map<String, dynamic>.from(e)),
    );
  }

  // ---------- Typed streams ----------

  static Stream<GpTomResult<GpTomTransactionResult>> get saleResults =>
      _typedResults<GpTomTransactionResult>(kind: GpTomEventKind.sale, parser: GpTomTransactionResult.fromJson);

  static Stream<GpTomResult<GpTomTransactionResult>> get refundResults =>
      _typedResults<GpTomTransactionResult>(kind: GpTomEventKind.refund, parser: GpTomTransactionResult.fromJson);

  static Stream<GpTomResult<GpTomTransactionResult>> get cancelResults =>
      _typedResults<GpTomTransactionResult>(kind: GpTomEventKind.cancel, parser: GpTomTransactionResult.fromJson);

  static Stream<GpTomResult<GpTomBatchResult>> get closeBatchResults =>
      _typedResults<GpTomBatchResult>(kind: GpTomEventKind.closeBatch, parser: GpTomBatchResult.fromJson);

  static Stream<GpTomResult<GpTomStateResult>> get stateResults =>
      _typedResults<GpTomStateResult>(kind: GpTomEventKind.state, parser: GpTomStateResult.fromJson);

  static Stream<GpTomResult<GpTomInquireResult>> get detailResults =>
      _typedResults<GpTomInquireResult>(kind: GpTomEventKind.detail, parser: GpTomInquireResult.fromJson);

  /// Must be called once (e.g. app startup).
  static Future<GpTomResult<void>> init(GpTomInitOptions options) async {
    try {
      final res = await _methodChannel.invokeMethod<Map>('init', options.toJson());
      _initialized = true;

      if (res == null) {
        return GpTomResult(code: GpTomResultCode.ok, message: 'Initialized');
      }
      return GpTomResult.fromMap<void>(res.cast<Object?, Object?>());
    } catch (e) {
      return GpTomResult(code: GpTomResultCode.internalError, message: e.toString());
    }
  }

  /// Checks if GP tom app is installed/available.
  static Future<GpTomResult<bool>> isInstalled() async {
    return _invoke<bool>('isInstalled');
  }

  static Future<GpTomResult<GpTomRegisterResult>> register(GpTomRegisterRequest request) async {
    return _invoke<GpTomRegisterResult>(
      'register',
      args: request.toJson(),
      dataParser: (d) => GpTomRegisterResult.fromJson((d as Map).cast<String, dynamic>()),
    );
  }

  /// Runs a sale/refund/cancel. For Android, the plugin will internally register first
  /// to obtain a transactionId and store a pending record.
  static Future<GpTomResult<void>> transaction(GpTomTransactionRequest request) async {
    return _invoke<void>('transaction', args: request.toJson());
  }

  /// Convenience wrapper for REFUND. Equivalent to calling [transaction] with a refund request.
  static Future<GpTomResult<void>> refund(GpTomTransactionRequest request) async {
    if (request.transactionType != GpTomTransactionType.refund) {
      return GpTomResult(
        code: GpTomResultCode.invalidArgument,
        message: 'Request.type must be refund',
        transactionId: request.transactionId,
      );
    }

    return transaction(request);
  }

  /// Convenience wrapper for CANCEL. Equivalent to calling [transaction] with a storno request.
  static Future<GpTomResult<void>> storno(GpTomTransactionRequest request) async {
    if (request.transactionType != GpTomTransactionType.storno) {
      return GpTomResult(
        code: GpTomResultCode.invalidArgument,
        message: 'Request.type must be storno',
        transactionId: request.transactionId,
      );
    }

    return transaction(request);
  }

  /// Android: calls stateRequest; iOS: not available -> returns PLATFORM_NOT_SUPPORTED.
  static Future<GpTomResult<void>> getState(String transactionId) async {
    return _invoke<void>('getState', args: {JsonKeys.transactionId: transactionId});
  }

  /// Android: TransactionInquire; iOS: transactionDetail deeplink.
  static Future<GpTomResult<void>> getDetail(String transactionId) async {
    return _invoke<void>('getDetail', args: {JsonKeys.transactionId: transactionId});
  }

  static Future<GpTomResult<void>> closeBatch() async {
    final reg = await register(GpTomRegisterRequest(originReferenceNum: null, clientId: null, persistPending: false));
    final transactionId = reg.data?.transactionId;

    if (reg.code != GpTomResultCode.ok || transactionId == null || transactionId.isEmpty) {
      return GpTomResult<void>(
        code: reg.code,
        message: reg.message ?? 'closeBatch: register failed',
        transactionId: transactionId,
      );
    }

    return transaction(
      GpTomTransactionRequest(transactionId: transactionId, transactionType: GpTomTransactionType.closeBatch),
    );
  }

  /// Legacy closeBatch flow.
  ///
  /// - Android: uses the original V2 callback path (no state polling). Result is
  ///   mapped directly via `BatchMapper` from `TransactionResultV2Entity`.
  /// - iOS: identical to [closeBatch] (deeplink flow).
  ///
  /// Both deliver the result via [closeBatchResults] stream.
  static Future<GpTomResult<void>> closeBatchLegacy() async {
    final reg = await register(GpTomRegisterRequest(originReferenceNum: null, clientId: null, persistPending: false));
    final transactionId = reg.data?.transactionId;

    if (reg.code != GpTomResultCode.ok || transactionId == null || transactionId.isEmpty) {
      return GpTomResult<void>(
        code: reg.code,
        message: reg.message ?? 'closeBatchLegacy: register failed',
        transactionId: transactionId,
      );
    }

    return _invoke<void>('closeBatchLegacy', args: {
      JsonKeys.transactionId: transactionId,
      JsonKeys.transactionType: GpTomTransactionType.closeBatch.code,
    });
  }

  /// Reads pending record stored by the plugin (Android: after register; iOS: after opening deeplink).
  static Future<GpTomResult<GpTomPendingRequest?>> getPending() async {
    return _invoke<GpTomPendingRequest?>(
      'getPending',
      dataParser: (result) {
        if (result == null) return null;

        final m = (result as Map).cast<String, dynamic>();
        if (m.isEmpty) return null;

        return GpTomPendingRequest.fromJson(m);
      },
    );
  }

  static Future<GpTomResult<void>> clearPending() async {
    return _invoke<void>('clearPending');
  }

  /// Cancels active state polling for a transaction (Android only).
  /// Sends a `cancelled` event to the matching result stream.
  static Future<GpTomResult<void>> cancelPolling(String transactionId) async {
    return _invoke<void>('cancelPolling', args: {JsonKeys.transactionId: transactionId});
  }

  static Future<GpTomResult<T>> _invoke<T>(
    String method, {
    Map<String, dynamic>? args,
    T Function(Object?)? dataParser,
  }) async {
    final String? txId = args?[JsonKeys.transactionId] as String?;

    if (!_initialized) return _notInit<T>(transactionId: txId);

    try {
      final res = await _methodChannel.invokeMethod<Map>(method, args);

      if (res == null) {
        return GpTomResult<T>(
          code: GpTomResultCode.internalError,
          message: 'Native returned null response',
          transactionId: txId,
        );
      }

      return GpTomResult.fromMap<T>(res.cast<Object?, Object?>(), dataParser: dataParser);
    } on MissingPluginException catch (e) {
      return GpTomResult<T>(
        code: GpTomResultCode.internalError,
        message: 'Plugin not registered: ${e.message}',
        transactionId: txId,
      );
    } on PlatformException catch (e) {
      return GpTomResult<T>(
        code: GpTomResultCode.internalError,
        message: e.message ?? e.code,
        transactionId: txId,
      );
    } catch (e) {
      return GpTomResult<T>(code: GpTomResultCode.internalError, message: e.toString(), transactionId: txId);
    }
  }

  static GpTomResult<T> _notInit<T>({String? transactionId}) {
    return GpTomResult<T>(
      code: GpTomResultCode.notInitialized,
      message: 'Call GpTomManager.init() first',
      transactionId: transactionId,
    );
  }

  static Stream<GpTomResult<T>> _typedResults<T>({
    required GpTomEventKind kind,
    required T Function(Map<String, dynamic>) parser,
  }) {
    return events.where((e) => e.kind == kind).map((e) => _eventToResult<T>(e, parser));
  }

  static GpTomResult<T> _eventToResult<T>(GpTomEvent e, T Function(Map<String, dynamic>) parser) {
    return GpTomResult.fromMap<T>(e.fullMap, dataParser: (d) => parser(Map<String, dynamic>.from(d as Map)));
  }
}
