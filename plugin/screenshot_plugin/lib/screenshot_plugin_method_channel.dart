import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'screenshot_plugin_platform_interface.dart';

/// An implementation of [ScreenshotPluginPlatform] that uses method channels.
class MethodChannelScreenshotPlugin extends ScreenshotPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('screenshot_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> takeScreenshot() async {
    final path = await methodChannel.invokeMethod<String>('takeScreenshot');
    return path;
  }

  @override
  Future<bool?> requestPermission() async {
    return await methodChannel.invokeMethod('requestPermission');
  }

  @override
  Future<void> stopScreenshot() async {
    return await methodChannel.invokeMethod('stopScreenshot');
  }
}
