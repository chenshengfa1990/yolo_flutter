import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'opencv_plugin_platform_interface.dart';

/// An implementation of [OpencvPluginPlatform] that uses method channels.
class MethodChannelOpencvPlugin extends OpencvPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('opencv_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> startDetectImage(String imagePath) async {
    await methodChannel.invokeMethod<List<dynamic>?>('detectImage', {'imagePath': imagePath});
  }

  @override
  Future<void> cropTemplate(String imagePath, String outputName, int xLTop, int yLTop, int xRBottom, int yRBottom) async {
    await methodChannel.invokeMethod<List<dynamic>?>('cropTemplate', {'imagePath': imagePath, 'outputName': outputName, 'xLTop': xLTop, 'yLTop': yLTop, 'xRBottom': xRBottom, 'yRBottom': yRBottom});
  }


}
