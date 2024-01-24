import 'upload_plugin_platform_interface.dart';

class UploadPlugin {
  Future<String?> getPlatformVersion() {
    return UploadPluginPlatform.instance.getPlatformVersion();
  }

  Future<String?> getQiqiuUploadToken() {
    return UploadPluginPlatform.instance.getQiqiuUploadToken();
  }
}
