
import 'inference_model.dart';
import 'tensorflow_plugin_platform_interface.dart';

class TensorflowPlugin {
  Future<String?> getPlatformVersion() {
    return TensorflowPluginPlatform.instance.getPlatformVersion();
  }

  Future<List<InferenceModel>> startInference(String imagePath) {
    return TensorflowPluginPlatform.instance.startInference(imagePath);
  }
}
