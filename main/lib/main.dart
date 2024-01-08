import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bug_logger/flutter_logger.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:ncnn_plugin/export.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// import 'package:tensorflow_plugin/export.dart';
import 'package:yolo_flutter/screen_shot_manager.dart';
import 'package:yolo_flutter/strategy_manager.dart';

import 'game_status_manager.dart';
import 'landlord_manager.dart';
import 'landlord_recorder.dart';
import 'overlay_window_widget.dart';

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
    return ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: const MyHomePage(title: '智能记牌器'),
            builder: EasyLoading.init(),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // late TensorflowPlugin tensorflowPlugin;
  late NcnnPlugin ncnnPlugin;
  late ScreenShotManager screenShotManager;
  late LandlordManager landlordManager;

  int num = 0;
  int notice = 0;
  int screenWidth = 0;
  int screenHeight = 0;
  int hasDeleteScreenshot = 0;
  bool useGPU = false;
  int detectAverage = 0;

  @override
  void initState() {
    // tensorflowPlugin = TensorflowPlugin();
    ncnnPlugin = NcnnPlugin();
    screenShotManager = ScreenShotManager(ncnnPlugin);
    super.initState();
  }

  void _onDetectImage() async {
    // final ImagePicker picker = ImagePicker();
    // var selectImage = await picker.getImage(source: ImageSource.gallery);

    // if (selectImage?.path.isNotEmpty ?? false) {
    //   List<InferenceModel> result = await tensorflowPlugin.startInference(selectImage!.path);
    //   print(result);
    // }
    EasyLoading.show(dismissOnTap: false);
    int before = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < 10; i++) {
      await ncnnPlugin.startDetectImage('', test: true);
    }
    int after = DateTime.now().millisecondsSinceEpoch;

    setState(() {
      detectAverage = (after - before) ~/ 10.0;
    });
    EasyLoading.dismiss();
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

    await FlutterOverlayWindow.showOverlay(
      width: 305,
      height: 62,
      alignment: OverlayAlignment.bottomCenter,
      overlayTitle: '牌面识别中',
      flag: OverlayFlag.clickThrough,
      // enableDrag: true,
      // positionGravity: PositionGravity.left,
    );

    await screenShotManager.requestPermission();
    screenShotManager.startScreenshotPeriodic();
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
    setState(() {
      hasDeleteScreenshot = 0;
    });
    screenShotManager.destroy();
    GameStatusManager.destroy();
    LandlordManager.destroy();
    StrategyManager.destroy();
    LandlordRecorder.destroy();
    FlutterOverlayWindow.closeOverlay();
  }

  void zipScreenshotFile() async {
    DateTime now = DateTime.now();
    var zipFileName = '${DateFormat('yyyyMMdd-HHmmss-SSS').format(now)}.zip';
    var zipPath = '${(await getExternalStorageDirectory())?.path}/$zipFileName';
    Directory cacheDir = await getTemporaryDirectory();

    ZipFileEncoder().zipDirectory(cacheDir, filename: zipPath);
    cacheDir.delete(recursive: true);

    // List<FileSystemEntity> files = cacheDir.listSync(recursive: true);
    //
    // Archive archive = Archive();
    //
    // for (var file in files) {
    //   if (file is File) {
    //     String filePath = file.path;
    //     String relativePath = filePath.substring(cacheDir.path.length + 1);
    //
    //     archive.addFile(ArchiveFile(relativePath, file.lengthSync(), file.readAsBytesSync()));
    //   }
    // }
    //
    // List<int>? encodedZip = ZipEncoder().encode(archive);
    //
    // File(zipPath).writeAsBytes(encodedZip!);
  }

  void _zipScreenshot() async {
    zipScreenshotFile();
  }

  void _test() async {
    setState(() {
      hasDeleteScreenshot = 0;
    });

    Directory? cacheDir = await getExternalStorageDirectory();
    deleteCacheScreenshot('${cacheDir?.path}/Pictures');

    setState(() {
      hasDeleteScreenshot = 1;
    });
  }

  void deleteCacheScreenshot(String path) {
    Directory directory = Directory(path);
    if (directory.existsSync()) {
      directory.listSync(recursive: true).forEach((element) {
        if (element is File) {
          element.deleteSync();
        } else if (element is Directory) {
          deleteCacheScreenshot(element.path);
          element.deleteSync();
        }
      });
    }
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // Text(
                //   '$num张纸牌',
                //   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColorConstant.colorGrey1),
                // ),
                // GestureDetector(
                //   onTap: _onDetectImage,
                //   child: Text(
                //     '检测图片',
                //     style: Theme.of(context).textTheme.headline4,
                //   ),
                // ),
                // const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      Text(
                        'GPU硬解',
                        style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      Expanded(child: Container()),
                      Switch(
                        value: useGPU,
                        onChanged: (value) {
                          setState(() {
                            useGPU = value;
                            ncnnPlugin.setGPU(useGPU);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: GestureDetector(
                    onTap: _test,
                    child: Text(
                      '删除截图缓存 $hasDeleteScreenshot',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: GestureDetector(
                    onTap: _onDetectImage,
                    child: Row(
                      children: [
                        Text(
                          '手机性能测试: ',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        Text(
                          '$detectAverage ms/张图',
                          style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 18.sp),
                        ),
                      ],
                    ),
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
  runApp(const OverlayWindowWidget());
}
