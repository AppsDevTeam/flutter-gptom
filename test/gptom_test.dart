import 'package:flutter_test/flutter_test.dart';
import 'package:gptom/gptom.dart';
import 'package:gptom/gptom_method_channel.dart';
import 'package:gptom/gptom_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGptomPlatform with MockPlatformInterfaceMixin implements GptomPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final GptomPlatform initialPlatform = GptomPlatform.instance;

  test('$MethodChannelGptom is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelGptom>());
  });

  test('getPlatformVersion', () async {
    Gptom GpTomPlugin = Gptom();
    MockGptomPlatform fakePlatform = MockGptomPlatform();
    GptomPlatform.instance = fakePlatform;

    expect(await GpTomPlugin.getPlatformVersion(), '42');
  });
}
