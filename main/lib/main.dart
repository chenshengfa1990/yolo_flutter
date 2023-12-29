import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bug_logger/flutter_logger.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ncnn_plugin/export.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot_plugin/screenshot_plugin.dart';
import 'package:tensorflow_plugin/export.dart';
import 'package:yolo_flutter/util/colorConstant.dart';

import 'overlay_window.dart';

void main() {
  initWidgetError();
  runApp(const MyApp());
}

void initWidgetError() {
  FlutterError.onError = (FlutterErrorDetails details) {
    Logger.i(details);
  };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '智能记牌器'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TensorflowPlugin tensorflowPlugin;
  late NcnnPlugin ncnnPlugin;
  late ScreenshotPlugin screenshotPlugin;
  Timer? screenshotTimer;

  int num = 0;
  int notice = 0;
  int screenWidth = 0;
  int screenHeight = 0;

  @override
  void initState() {
    tensorflowPlugin = TensorflowPlugin();
    ncnnPlugin = NcnnPlugin();
    screenshotPlugin = ScreenshotPlugin();
    super.initState();
    // Timer.periodic(const Duration(milliseconds: 1000), (timer) {
    //   _updateNotice();
    // });
  }

  void _showLog() async {
    // final ImagePicker picker = ImagePicker();
    // var inferenceImage = await picker.getImage(source: ImageSource.gallery);
    // if (inferenceImage?.path.isNotEmpty ?? false) {
    //   List<InferenceModel> result = await tensorflowPlugin.startInference(inferenceImage!.path);
    //   print(result);
    // }
    // ConsoleOverlay.show(context);

    Map<String, dynamic> httpParams = {};
    httpParams['num_cards_left_dict'] = {"landlord": 0, "landlord_down": 17, "landlord_up": 17};
    httpParams['action'] = {"position": "landlord", "need_play_card": true};
    httpParams['user_id'] = 123;
    httpParams['round'] = 1;
    httpParams["player_position"] = "landlord";
    httpParams['player_hand_cards'] = [3, 4, 4, 5, 5, 5, 6, 6, 7, 8, 9, 9, 11, 11, 12, 12, 13, 17, 17, 30];
    httpParams['three_landlord_cards'] = [17, 17, 1];
    // var jsonStr = json.encode(httpParams);
    // print(jsonStr);
    // Logger.i(jsonStr);
    // var res = await HttpUtils.post('http://172.16.3.225:7070/data', data: jsonStr);
    // // var res = await HttpUtils.get('http://172.16.3.225:7070/');
    // print(res);
  }

  void _onDetectImage() async {
    final ImagePicker picker = ImagePicker();
    var selectImage = await picker.getImage(source: ImageSource.gallery);

    // if (selectImage?.path.isNotEmpty ?? false) {
    //   List<InferenceModel> result = await tensorflowPlugin.startInference(selectImage!.path);
    //   print(result);
    // }

    if (selectImage?.path.isNotEmpty ?? false) {
      var result = await ncnnPlugin.startDetectImage(selectImage!.path);
      setState(() {
        num = result?.length ?? 0;
      });
    }
  }

  void _startGame() async {
    final bool status = await FlutterOverlayWindow.isPermissionGranted();
    if (!status) {
      bool? result = await FlutterOverlayWindow.requestPermission();
      if (result == false) {
        return;
      }
    }
    bool storagePermission = await checkStoragePermission();
    if (!storagePermission) {
      return;
    }

    await screenshotPlugin.requestPermission();

    await FlutterOverlayWindow.showOverlay(
      width: 450,
      height: 330,
      alignment: OverlayAlignment.topLeft,
      flag: OverlayFlag.defaultFlag,
      enableDrag: true,
    );
    _startScreenshotPeriodic();
  }

  Future<bool> checkStoragePermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    } else {
      return false;
    }
  }

  void _endGame() async {
    _stopScreenshot();
    await FlutterOverlayWindow.closeOverlay();
  }

  void _updateNotice() async {
    notice++;
    await FlutterOverlayWindow.shareData(notice);
  }

  void _startScreenshotPeriodic() {
    screenshotTimer = Timer.periodic(const Duration(milliseconds: 3000), (timer) async {
      String? path = await screenshotPlugin.takeScreenshot();
      print('yolo screenshot: $path');
    });
  }

  void _stopScreenshot() {
    screenshotTimer?.cancel();
    screenshotTimer = null;
    screenshotPlugin.stopScreenshot();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '$num张纸牌',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColorConstant.colorGrey1),
                ),
                GestureDetector(
                  onTap: _onDetectImage,
                  child: Text(
                    '检测图片',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
                GestureDetector(
                  onTap: _updateNotice,
                  child: Text(
                    '更新悬浮窗出牌提示',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _startGame,
                  child: Text(
                    '开始牌局',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
                const SizedBox(
                  width: 50,
                ),
                GestureDetector(
                  onTap: _endGame,
                  child: Text(
                    '结束牌局',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ],
            ),
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

// overlay entry point
@pragma("vm:entry-point")
void overlayMain() {
  runApp(const OverlayWindow());
}
