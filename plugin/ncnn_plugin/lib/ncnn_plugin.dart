
import 'ncnn_detect_model.dart';
import 'ncnn_plugin_platform_interface.dart';

class NcnnPlugin {
  bool useGPU = false;
  Future<String?> getPlatformVersion() {
    return NcnnPluginPlatform.instance.getPlatformVersion();
  }

  void setGPU(bool useGPU) {
    this.useGPU = useGPU;
  }

  Future<List<NcnnDetectModel>?> startDetectImage(String imagePath, {bool test = false}) {
    return NcnnPluginPlatform.instance.startDetectImage(imagePath, useGPU, test: test);
  }
}
