import 'dart:collection';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'inference_model.dart';
import 'tensorflow_plugin_method_channel.dart';

abstract class TensorflowPluginPlatform extends PlatformInterface {
  /// Constructs a TensorflowPluginPlatform.
  TensorflowPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static TensorflowPluginPlatform _instance = MethodChannelTensorflowPlugin();

  /// The default instance of [TensorflowPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelTensorflowPlugin].
  static TensorflowPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TensorflowPluginPlatform] when
  /// they register themselves.
  static set instance(TensorflowPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  ///开始检测
  Future<List<InferenceModel>> startInference(String imagePath);
}
