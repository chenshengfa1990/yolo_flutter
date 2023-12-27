
import 'ncnn_detect_model.dart';
import 'ncnn_plugin_platform_interface.dart';

class NcnnPlugin {
  Future<String?> getPlatformVersion() {
    return NcnnPluginPlatform.instance.getPlatformVersion();
  }

  Future<List<NcnnDetectModel>?> startDetectImage(String imagePath) {
    return NcnnPluginPlatform.instance.startDetectImage(imagePath);
  }
}
