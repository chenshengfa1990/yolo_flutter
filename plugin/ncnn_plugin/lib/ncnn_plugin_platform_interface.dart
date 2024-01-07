import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ncnn_detect_model.dart';
import 'ncnn_plugin_method_channel.dart';

abstract class NcnnPluginPlatform extends PlatformInterface {
  /// Constructs a NcnnPluginPlatform.
  NcnnPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static NcnnPluginPlatform _instance = MethodChannelNcnnPlugin();

  /// The default instance of [NcnnPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelNcnnPlugin].
  static NcnnPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NcnnPluginPlatform] when
  /// they register themselves.
  static set instance(NcnnPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  ///开始检测
  Future<List<NcnnDetectModel>?> startDetectImage(String imagePath, bool useGPU);
}
