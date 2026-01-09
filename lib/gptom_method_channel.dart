import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'gptom_platform_interface.dart';

/// An implementation of [GptomPlatform] that uses method channels.
class MethodChannelGptom extends GptomPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('gptom');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
