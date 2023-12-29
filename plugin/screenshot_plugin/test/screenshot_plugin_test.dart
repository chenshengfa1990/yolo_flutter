import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot_plugin/screenshot_plugin.dart';
import 'package:screenshot_plugin/screenshot_plugin_platform_interface.dart';
import 'package:screenshot_plugin/screenshot_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockScreenshotPluginPlatform
    with MockPlatformInterfaceMixin
    implements ScreenshotPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ScreenshotPluginPlatform initialPlatform = ScreenshotPluginPlatform.instance;

  test('$MethodChannelScreenshotPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelScreenshotPlugin>());
  });

  test('getPlatformVersion', () async {
    ScreenshotPlugin screenshotPlugin = ScreenshotPlugin();
    MockScreenshotPluginPlatform fakePlatform = MockScreenshotPluginPlatform();
    ScreenshotPluginPlatform.instance = fakePlatform;

    expect(await screenshotPlugin.getPlatformVersion(), '42');
  });
}
