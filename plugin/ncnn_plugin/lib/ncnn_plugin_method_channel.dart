import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ncnn_detect_model.dart';
import 'ncnn_plugin_platform_interface.dart';

/// An implementation of [NcnnPluginPlatform] that uses method channels.
class MethodChannelNcnnPlugin extends NcnnPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ncnn_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<List<NcnnDetectModel>?> startDetectImage(String imagePath, bool useGPU, {bool? test}) async {
    var res = await methodChannel.invokeMethod<List<dynamic>?>('detectImage', {'imagePath': imagePath, 'useGPU': useGPU, 'test': test});
    List<NcnnDetectModel> detectResList = [];
    res?.forEach((element) {
      var model = NcnnDetectModel.fromJson(jsonDecode(element));
      detectResList.add(model);
    });
    return detectResList;
  }
}
