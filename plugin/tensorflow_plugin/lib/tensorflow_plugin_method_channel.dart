import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'inference_model.dart';
import 'tensorflow_plugin_platform_interface.dart';

/// An implementation of [TensorflowPluginPlatform] that uses method channels.
class MethodChannelTensorflowPlugin extends TensorflowPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('tensorflow_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<List<InferenceModel>> startInference(String imagePath) async {
    var res = await methodChannel.invokeMethod<List<dynamic>?>('startInference', imagePath);
    List<InferenceModel> inferenceResList = [];
    res?.forEach((element) {
      Map listItem = element as Map;
      var model = InferenceModel();
      model.categoryId = listItem["category_id"];
      model.imageId = listItem["image_id"];
      model.score = listItem["score"];
      model.rect = listItem["bbox"];
      inferenceResList.add(model);
    });
    return inferenceResList;
  }
}
