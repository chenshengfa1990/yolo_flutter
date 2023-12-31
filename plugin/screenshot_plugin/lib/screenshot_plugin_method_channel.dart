import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'screenshot_plugin_platform_interface.dart';
import 'screenshot_model.dart';

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
  Future<ScreenshotModel?> takeScreenshot() async {
    var resJson = await methodChannel.invokeMethod<String>('takeScreenshot');
    if (resJson != null) {
      var resModel = ScreenshotModel.fromJson(jsonDecode(resJson));
      return resModel;
    }
    return null;
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
