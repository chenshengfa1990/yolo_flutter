import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncnn_plugin/ncnn_plugin_method_channel.dart';

void main() {
  MethodChannelNcnnPlugin platform = MethodChannelNcnnPlugin();
  const MethodChannel channel = MethodChannel('ncnn_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
