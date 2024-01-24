import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'upload_plugin_platform_interface.dart';

/// An implementation of [UploadPluginPlatform] that uses method channels.
class MethodChannelUploadPlugin extends UploadPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('upload_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> getQiqiuUploadToken() async {
    final token = await methodChannel.invokeMethod<String>('getQiniuToken');
    return token;
  }
}
