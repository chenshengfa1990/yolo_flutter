import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'upload_plugin_method_channel.dart';

abstract class UploadPluginPlatform extends PlatformInterface {
  /// Constructs a UploadPluginPlatform.
  UploadPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static UploadPluginPlatform _instance = MethodChannelUploadPlugin();

  /// The default instance of [UploadPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelUploadPlugin].
  static UploadPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UploadPluginPlatform] when
  /// they register themselves.
  static set instance(UploadPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> getQiqiuUploadToken();
}
