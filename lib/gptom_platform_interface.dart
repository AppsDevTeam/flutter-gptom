import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'gptom_method_channel.dart';

abstract class GptomPlatform extends PlatformInterface {
  /// Constructs a GptomPlatform.
  GptomPlatform() : super(token: _token);

  static final Object _token = Object();

  static GptomPlatform _instance = MethodChannelGptom();

  /// The default instance of [GptomPlatform] to use.
  ///
  /// Defaults to [MethodChannelGptom].
  static GptomPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [GptomPlatform] when
  /// they register themselves.
  static set instance(GptomPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
