import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'opencv_plugin_method_channel.dart';

abstract class OpencvPluginPlatform extends PlatformInterface {
  /// Constructs a OpencvPluginPlatform.
  OpencvPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static OpencvPluginPlatform _instance = MethodChannelOpencvPlugin();

  /// The default instance of [OpencvPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelOpencvPlugin].
  static OpencvPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [OpencvPluginPlatform] when
  /// they register themselves.
  static set instance(OpencvPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> startDetectImage(String imagePath);

  Future<void> cropTemplate(String imagePath, String outputName, int xLTop, int yLTop, int xRBottom, int yRBottom);
}
