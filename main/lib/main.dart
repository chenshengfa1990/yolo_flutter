import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:ncnn_plugin/export.dart';

// import 'package:opencv_plugin/opencv_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yolo_flutter/landlord/landlord_type.dart';

// import 'package:tensorflow_plugin/export.dart';
import 'package:yolo_flutter/screenshot/screen_shot_manager.dart';
import 'package:yolo_flutter/screenshot/screenshot_factory.dart';
import 'package:yolo_flutter/status/game_status_factory.dart';
import 'package:yolo_flutter/strategy_manager.dart';
import 'package:yolo_flutter/strategy_queue.dart';
import 'package:yolo_flutter/user_manager.dart';
import 'package:yolo_flutter/util/common_util.dart';
import 'package:yolo_flutter/util/dialog_util.dart';
import 'package:yolo_flutter/view/feed_back.dart';

import 'landlord/landlord_manager.dart';
import 'landlord_recorder.dart';
import 'overlay_window_widget.dart';

const String LOG_TAG = 'YoloApp';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initXLog();
  await UserManager.init();
  initWidgetError();
  runApp(const MyApp());
}

Future<void> initXLog() async {
  var cacheDir = (await getApplicationCacheDirectory()).path;
  var logDir = (await getExternalCacheDirectories())?[0].path ?? cacheDir;

  return await XLog.open(XLogConfig(cacheDir: cacheDir, logDir: logDir, namePrefix: 'yolo_xlog', consoleLogOpen: true));
}

void initWidgetError() {
  FlutterError.onError = (FlutterErrorDetails details) {
    XLog.i(LOG_TAG, details.toString());
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
            title: 'AI万能记牌器',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: const MyHomePage(title: 'AI万能记牌器'),
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

  // late OpencvPlugin opencvPlugin;
  ScreenShotManager? iScreenShotManager;
  late LandlordManager landlordManager;
  late TextEditingController editTextController;
  late FocusNode focusNode;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int num = 0;
  int notice = 0;
  int screenWidth = 0;
  int screenHeight = 0;
  bool useGPU = true;
  int detectAverage = 0;
  int opencvDetectNum = 0;
  int leftSecond = 0;

  @override
  void initState() {
    super.initState();
    // tensorflowPlugin = TensorflowPlugin();
    ncnnPlugin = NcnnPlugin();
    // opencvPlugin = OpencvPlugin();
    // screenShotManager = ScreenShotManager(ncnnPlugin);
    initTextField();
    getSharePreference();
    CommonUtil.init();
    XLog.i(LOG_TAG, "app init, isDebugMode:$kDebugMode");
  }

  @override
  void dispose() {
    super.dispose();
    editTextController.dispose();
    focusNode.dispose();
  }

  void initTextField() {
    focusNode = FocusNode();
    editTextController = TextEditingController();
  }

  void getSharePreference() async {
    final SharedPreferences prefs = await _prefs;
    useGPU = (prefs.get('useGPU') ?? true) as bool;
    editTextController.text = prefs.getString('loginToken') ?? "";
    LandlordManager.curLandlordType = LandlordType.values[prefs.getInt("landlordType") ?? 0];
    setState(() {});
    updateOutDate();
  }

  void updateOutDate() async {
    XLog.i(LOG_TAG, 'updateOutDate');
    if (editTextController.text.isNotEmpty) {
      leftSecond = await UserManager.requestUserOutDate(editTextController.text);
      setState(() {});
    }
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
    XLog.i(LOG_TAG, "test detectAverage is ${detectAverage}ms");
  }

  // void _opencvDetect() async {
  //   final ImagePicker picker = ImagePicker();
  //   var selectImage = await picker.getImage(source: ImageSource.gallery);
  //   if (selectImage?.path.isNotEmpty ?? false) {
  //     // opencvPlugin.startDetectImage(selectImage!.path, LandlordType.tx.index, RegionType.handCard.index);
  //     opencvPlugin.cropTemplate(selectImage!.path, "/weile_buchu.png", RegionFactory.getRegion(LandlordType.weile, RegionType.leftSkip));
  //   }
  // }

  void showFeedbackDialog() {
    DialogUtil.showCustomDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const FeedbackPage();
        });
  }

  void _startGame() async {
    XLog.i(LOG_TAG, "_startGame");

    if (iScreenShotManager?.isGameRunning == true) {
      XLog.i(LOG_TAG, "game running, cannot start again!!!!!");
      Fluttertoast.showToast(msg: "牌局进行中");
      return;
    }
    focusNode.unfocus();
    bool loginResult = await UserManager.userLogin(editTextController.text);
    if (loginResult == false) {
      return;
    }
    bool storagePermission = await checkStoragePermission();
    if (!storagePermission) {
      XLog.i(LOG_TAG, "storagePermission deny");
      Fluttertoast.showToast(msg: "请开启存储权限");
      return;
    }

    final bool status = await FlutterOverlayWindow.isPermissionGranted();
    if (!status) {
      bool? result = await FlutterOverlayWindow.requestPermission();
      if (result == false) {
        XLog.i(LOG_TAG, "FlutterOverlayWindow permission deny");
        Fluttertoast.showToast(msg: "请开启浮窗权限");
        return;
      }
    }

    iScreenShotManager = ScreenshotFactory.getScreenshotManager(LandlordManager.curLandlordType, ncnnPlugin);
    bool screenshotPermission = await iScreenShotManager?.requestPermission() ?? false;
    if (!screenshotPermission) {
      XLog.i(LOG_TAG, "ScreenShot permission deny");
      Fluttertoast.showToast(msg: "请开启截屏权限");
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
    XLog.i(LOG_TAG, "start screenshot, LandlordType: ${LandlordManager.curLandlordType}");
    // Fluttertoast.showToast(msg: "去体验${LandlordManager.landlordName[LandlordManager.curLandlordType]}吧");

    iScreenShotManager?.startScreenshotRepeat();
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
    updateOutDate();
    focusNode.unfocus();
    iScreenShotManager?.destroy();
    GameStatusFactory.getStatusManager().destroy();
    LandlordManager.destroy();
    StrategyManager().destroy();
    StrategyQueue().destroy();
    LandlordRecorder.destroy();
    FlutterOverlayWindow.closeOverlay();
    XLog.i(LOG_TAG, "_endGame");
    XLog.flush();
  }

  void _delete() async {
    if (iScreenShotManager?.isGameRunning == true) {
      Fluttertoast.showToast(msg: "牌局进行中");
      return;
    }
    EasyLoading.show(dismissOnTap: false);
    Directory? cacheDir = await getExternalStorageDirectory();
    deleteCacheScreenshot('${cacheDir?.path}/Pictures');

    XLog.i(LOG_TAG, "deleteCacheScreenshot cache");
    EasyLoading.dismiss();
    Fluttertoast.showToast(msg: '删除成功');
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

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(Duration.secondsPerMinute));
    if (duration.inDays > 0) {
      return "${duration.inDays}天 ${twoDigits(duration.inHours.remainder(Duration.hoursPerDay))}小时 $twoDigitMinutes分钟";
    } else if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}小时 $twoDigitMinutes分钟";
    } else {
      return "$twoDigitMinutes分钟";
    }
  }

  Widget buildDropdownButton() {
    return DropdownButton(
      value: LandlordManager.curLandlordType,
      items: [
        DropdownMenuItem(value: LandlordType.huanle, child: Text(LandlordManager.landlordName[LandlordType.huanle]!)),
        DropdownMenuItem(value: LandlordType.weile, child: Text(LandlordManager.landlordName[LandlordType.weile]!)),
        DropdownMenuItem(value: LandlordType.tuyou, child: Text(LandlordManager.landlordName[LandlordType.tuyou]!)),
      ],
      onChanged: (value) {
        setState(() {
          if (iScreenShotManager?.isGameRunning == true) {
            Fluttertoast.showToast(msg: "牌局进行中");
            return;
          }
          _prefs.then((preference) => preference.setInt('landlordType', (value as LandlordType).index));
          LandlordManager.curLandlordType = value as LandlordType;
          XLog.i(LOG_TAG, "select landlordType:  ${LandlordManager.curLandlordType}");
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    '有效期: ${formatDuration(Duration(seconds: leftSecond))}',
                    style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.normal),
                  ),
                ),
                const SizedBox(height: 10),
                //激活码
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(
                              height: 50,
                              alignment: Alignment.topLeft,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.04),
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Container(),
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: TextField(
                                focusNode: focusNode,
                                controller: editTextController,
                                style: TextStyle(fontSize: 16.0, color: Colors.black.withOpacity(0.8)),
                                decoration: InputDecoration(
                                  hintText: "激活码",
                                  hintStyle: TextStyle(
                                    color: Colors.black.withOpacity(0.2),
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  counterText: '',
                                  border: InputBorder.none,
                                ),
                                cursorColor: Colors.blue,
                                maxLines: 1,
                                textAlign: TextAlign.start,
                                autofocus: false,
                                keyboardType: TextInputType.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 100,
                        margin: const EdgeInsets.only(left: 10),
                        alignment: Alignment.topLeft,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.04),
                          borderRadius: const BorderRadius.all(Radius.circular(15)),
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            if (editTextController.text.isNotEmpty) {
                              _prefs.then((preference) => preference.setString('loginToken', editTextController.text));
                              UserManager.loginToken = editTextController.text;
                              leftSecond = await UserManager.requestUserOutDate(editTextController.text);
                              focusNode.unfocus();
                              setState(() {});
                            }
                          },
                          child: const Center(
                            child: Text(
                              '保存',
                              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //硬件加速
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      Text(
                        'GPU硬件加速',
                        style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      Expanded(child: Container()),
                      Switch(
                        value: useGPU,
                        onChanged: (value) {
                          setState(() {
                            _prefs.then((preference) => preference.setBool('useGPU', value));
                            XLog.i(LOG_TAG, "GPU硬件加速$value");
                            useGPU = value;
                            ncnnPlugin.setGPU(useGPU);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                //下拉选择
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: buildDropdownButton(),
                ),
                //删除截图
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: GestureDetector(
                    onTap: _delete,
                    child: Text(
                      '删除截图缓存',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Container(
                //   padding: const EdgeInsets.only(left: 10),
                //   child: GestureDetector(
                //     onTap: _onDetectImage,
                //     child: Row(
                //       children: [
                //         Text(
                //           'yolo性能测试: ',
                //           style: Theme.of(context).textTheme.headline5,
                //         ),
                //         Text(
                //           '$detectAverage ms/张图',
                //           style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 18.sp),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: GestureDetector(
                    onTap: showFeedbackDialog,
                    child: Row(
                      children: [
                        Text(
                          '问题反馈',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ],
                    ),
                  ),
                ),
                // const SizedBox(height: 10),
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
                  onTap: _endGame,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.08),
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Text(
                      '结束牌局',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: _startGame,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.08),
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Text(
                      '开始牌局',
                      style: Theme.of(context).textTheme.headline4,
                    ),
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
