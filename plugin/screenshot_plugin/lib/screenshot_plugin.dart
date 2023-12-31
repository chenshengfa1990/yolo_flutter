
import 'package:screenshot_plugin/screenshot_model.dart';

import 'screenshot_plugin_platform_interface.dart';

class ScreenshotPlugin {
  Future<String?> getPlatformVersion() {
    return ScreenshotPluginPlatform.instance.getPlatformVersion();
  }

  Future<ScreenshotModel?> takeScreenshot() async {
    return await ScreenshotPluginPlatform.instance.takeScreenshot();
  }

  Future<void> stopScreenshot() async {
    return await ScreenshotPluginPlatform.instance.stopScreenshot();
  }

  Future<bool?> requestPermission() async {
    return await ScreenshotPluginPlatform.instance.requestPermission();
  }
}
