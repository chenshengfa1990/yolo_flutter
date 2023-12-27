import 'package:flutter_test/flutter_test.dart';
import 'package:ncnn_plugin/ncnn_plugin.dart';
import 'package:ncnn_plugin/ncnn_plugin_platform_interface.dart';
import 'package:ncnn_plugin/ncnn_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNcnnPluginPlatform
    with MockPlatformInterfaceMixin
    implements NcnnPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NcnnPluginPlatform initialPlatform = NcnnPluginPlatform.instance;

  test('$MethodChannelNcnnPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNcnnPlugin>());
  });

  test('getPlatformVersion', () async {
    NcnnPlugin ncnnPlugin = NcnnPlugin();
    MockNcnnPluginPlatform fakePlatform = MockNcnnPluginPlatform();
    NcnnPluginPlatform.instance = fakePlatform;

    expect(await ncnnPlugin.getPlatformVersion(), '42');
  });
}
