
import 'gptom_platform_interface.dart';

class Gptom {
  Future<String?> getPlatformVersion() {
    return GptomPlatform.instance.getPlatformVersion();
  }
}
