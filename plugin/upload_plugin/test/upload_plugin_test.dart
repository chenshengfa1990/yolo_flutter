import 'package:flutter_test/flutter_test.dart';
import 'package:upload_plugin/upload_plugin.dart';
import 'package:upload_plugin/upload_plugin_platform_interface.dart';
import 'package:upload_plugin/upload_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockUploadPluginPlatform with MockPlatformInterfaceMixin implements UploadPluginPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final UploadPluginPlatform initialPlatform = UploadPluginPlatform.instance;

  test('$MethodChannelUploadPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelUploadPlugin>());
  });

  test('getPlatformVersion', () async {
    UploadPlugin uploadPlugin = UploadPlugin();
    MockUploadPluginPlatform fakePlatform = MockUploadPluginPlatform();
    UploadPluginPlatform.instance = fakePlatform;

    expect(await uploadPlugin.getPlatformVersion(), '42');
  });
}
