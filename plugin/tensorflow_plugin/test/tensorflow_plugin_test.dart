import 'package:flutter_test/flutter_test.dart';
import 'package:tensorflow_plugin/tensorflow_plugin.dart';
import 'package:tensorflow_plugin/tensorflow_plugin_platform_interface.dart';
import 'package:tensorflow_plugin/tensorflow_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTensorflowPluginPlatform
    with MockPlatformInterfaceMixin
    implements TensorflowPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TensorflowPluginPlatform initialPlatform = TensorflowPluginPlatform.instance;

  test('$MethodChannelTensorflowPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTensorflowPlugin>());
  });

  test('getPlatformVersion', () async {
    TensorflowPlugin tensorflowPlugin = TensorflowPlugin();
    MockTensorflowPluginPlatform fakePlatform = MockTensorflowPluginPlatform();
    TensorflowPluginPlatform.instance = fakePlatform;

    expect(await tensorflowPlugin.getPlatformVersion(), '42');
  });
}
