import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:screenshot_plugin/screenshot_model.dart';

import 'screenshot_plugin_method_channel.dart';

abstract class ScreenshotPluginPlatform extends PlatformInterface {
  /// Constructs a ScreenshotPluginPlatform.
  ScreenshotPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static ScreenshotPluginPlatform _instance = MethodChannelScreenshotPlugin();

  /// The default instance of [ScreenshotPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelScreenshotPlugin].
  static ScreenshotPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ScreenshotPluginPlatform] when
  /// they register themselves.
  static set instance(ScreenshotPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<ScreenshotModel?> takeScreenshot();
  Future<void> stopScreenshot();

  Future<bool> requestPermission();
}
