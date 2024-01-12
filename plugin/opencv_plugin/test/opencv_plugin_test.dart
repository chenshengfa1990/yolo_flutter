import 'package:flutter_test/flutter_test.dart';
import 'package:opencv_plugin/opencv_plugin.dart';
import 'package:opencv_plugin/opencv_plugin_platform_interface.dart';
import 'package:opencv_plugin/opencv_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockOpencvPluginPlatform with MockPlatformInterfaceMixin implements OpencvPluginPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final OpencvPluginPlatform initialPlatform = OpencvPluginPlatform.instance;

  test('$MethodChannelOpencvPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelOpencvPlugin>());
  });

  test('getPlatformVersion', () async {
    OpencvPlugin opencvPlugin = OpencvPlugin();
    MockOpencvPluginPlatform fakePlatform = MockOpencvPluginPlatform();
    OpencvPluginPlatform.instance = fakePlatform;

    expect(await opencvPlugin.getPlatformVersion(), '42');
  });
}
