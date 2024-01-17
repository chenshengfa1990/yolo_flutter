import 'opencv_plugin_platform_interface.dart';

class OpencvPlugin {
  Future<String?> getPlatformVersion() {
    return OpencvPluginPlatform.instance.getPlatformVersion();
  }

  Future<void> startDetectImage(String imagePath) {
    return OpencvPluginPlatform.instance.startDetectImage(imagePath);
  }

  Future<void> cropTemplate(String imagePath, String outputName, int xLTop, int yLTop, int xRBottom, int yRBottom) {
    return OpencvPluginPlatform.instance.cropTemplate(imagePath, outputName, xLTop, yLTop, xRBottom, yRBottom);
  }
}
