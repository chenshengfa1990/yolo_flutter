import 'dart:ui';

import 'opencv_plugin_platform_interface.dart';

class OpencvPlugin {
  Future<String?> getPlatformVersion() {
    return OpencvPluginPlatform.instance.getPlatformVersion();
  }

  Future<void> startDetectImage(String imagePath, int landLordType, int regionType) {
    return OpencvPluginPlatform.instance.startDetectHandCard(imagePath, landLordType, regionType);
  }

  Future<void> cropTemplate(String imagePath, String outputName, Rect region) {
    return OpencvPluginPlatform.instance
        .cropTemplate(imagePath, outputName, region.left as int, region.top as int, region.right as int, region.bottom as int);
  }
}
