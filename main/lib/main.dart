import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bug_logger/console_overlay.dart';
import 'package:flutter_bug_logger/flutter_logger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ncnn_plugin/export.dart';
import 'package:tensorflow_plugin/export.dart';
import 'package:yolo_flutter/http/httpUtils.dart';
import 'package:yolo_flutter/util/fontStyleConstant.dart';
import 'package:yolo_flutter/util/colorConstant.dart';

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
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.blue,
          ),
          home: const MyHomePage(title: 'Flutter Demo Home Page'),
        );
      }
      // child: MaterialApp(
      //   title: 'Flutter Demo',
      //   theme: ThemeData(
      //     // This is the theme of your application.
      //     //
      //     // Try running your application with "flutter run". You'll see the
      //     // application has a blue toolbar. Then, without quitting the app, try
      //     // changing the primarySwatch below to Colors.green and then invoke
      //     // "hot reload" (press "r" in the console where you ran "flutter run",
      //     // or simply save your changes to "hot reload" in a Flutter IDE).
      //     // Notice that the counter didn't reset back to zero; the application
      //     // is not restarted.
      //     primarySwatch: Colors.blue,
      //   ),
      //   home: const MyHomePage(title: 'Flutter Demo Home Page'),
      // ),
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
  int num = 0;

  @override
  void initState() {
    tensorflowPlugin = TensorflowPlugin();
    ncnnPlugin = NcnnPlugin();
    Logger.init(
      true,// isEnable ，if production ，please false
      isShowFile: true, // In the IDE, whether the file name is displayed
      isShowTime: true, // In the IDE, whether the time is displayed
      isShowNavigation: true, // In the IDE, When clicked, it jumps to the printed file details page
      levelVerbose: 247, // In the IDE, Set the color
      levelDebug: 26,
      levelInfo: 28,
      levelWarn: 3,
      levelError: 9,
      phoneVerbose: Colors.white54, // In your phone or web，, Set the color
      phoneDebug: Colors.blue,
      phoneInfo: Colors.green,
      phoneWarn: Colors.yellow,
      phoneError: Colors.redAccent,
    );

    super.initState();
  }

  void _showLog() async {
    // final ImagePicker picker = ImagePicker();
    // var inferenceImage = await picker.getImage(source: ImageSource.gallery);
    // if (inferenceImage?.path.isNotEmpty ?? false) {
    //   List<InferenceModel> result = await tensorflowPlugin.startInference(inferenceImage!.path);
    //   print(result);
    // }
    // ConsoleOverlay.show(context);

    // Map<String, dynamic> httpParams = {};
    // httpParams['num_cards_left_dict'] = {"landlord": 0, "landlord_down": 17, "landlord_up": 17};
    // httpParams['action'] = {"position": "landlord", "need_play_card": true};
    // httpParams['user_id'] = 123;
    // httpParams['round'] = 1;
    // httpParams["player_position"] = "landlord";
    // httpParams['player_hand_cards'] = [3, 4, 4, 5, 5, 5, 6, 6, 7, 8, 9, 9, 11, 11, 12, 12, 13, 17, 17, 30];
    // httpParams['three_landlord_cards'] = [17, 17, 1];
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$num张纸牌', style: FontStyleConstant.fontStylew500_16.apply(color: AppColorConstant.colorGrey1),
            ),
            GestureDetector(
              onTap: _onDetectImage,
              child: Text(
                '检测图片',
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showLog,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
