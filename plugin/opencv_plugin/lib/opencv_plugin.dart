import 'opencv_plugin_platform_interface.dart';

class OpencvPlugin {
  Future<String?> getPlatformVersion() {
    return OpencvPluginPlatform.instance.getPlatformVersion();
  }
}
