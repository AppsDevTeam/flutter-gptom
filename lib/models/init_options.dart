import 'package:gptom/utils/json_keys.dart';
import 'package:meta/meta.dart';

@immutable
class GpTomInitOptions {
  /// If true, Android package name will be `com.globalpayments.atom.dev`.
  /// Otherwise `com.globalpayments.atom`.
  final bool isDevelopment;

  /// iOS redirect URL that GP tom will call back to (e.g. `myapp://gptom`).
  ///
  /// You must register the scheme in your iOS app.
  final String? iosRedirectUrl;

  final bool debugLogs;

  const GpTomInitOptions({this.isDevelopment = false, this.iosRedirectUrl, this.debugLogs = false});

  Map<String, dynamic> toJson() => {
    JsonKeys.isDevelopment: isDevelopment,
    JsonKeys.iosRedirectUrl: iosRedirectUrl,
    JsonKeys.debugLogs: debugLogs,
  };
}
