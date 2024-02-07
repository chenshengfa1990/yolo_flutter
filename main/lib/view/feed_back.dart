import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qiniu_flutter_sdk/qiniu_flutter_sdk.dart';
import 'package:upload_plugin/upload_plugin.dart';
import 'package:yolo_flutter/util/upload_util.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  String LOG_TAG = "Feedback";
  late TextEditingController editTextController;

  @override
  void initState() {
    super.initState();

    editTextController = TextEditingController();
    // controller.addListener(() {
    //   if (controller.text.isNotEmpty == true) {
    //     setState(() {});
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          child: Container(
              width: 315,
              height: 240,
              decoration: const BoxDecoration(color: Color(0xFF323237), borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Container()),
        ),
        Container(
            width: 315,
            height: 233.5,
            alignment: Alignment.bottomCenter,
            margin: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Text('问题反馈',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: const Color(0xFFFFFFFF).withOpacity(0.86), fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 10,
                ),

                ///输入框
                Container(
                  decoration:
                      BoxDecoration(color: const Color(0xFFFFFFFF).withOpacity(0.12), borderRadius: const BorderRadius.all(Radius.circular(10))),
                  width: 275,
                  margin: const EdgeInsets.only(top: 8.5),
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(top: 9, bottom: 9, left: 11, right: 11),
                    child: TextField(
                      autofocus: true,
                      controller: editTextController,
                      textAlign: TextAlign.left,
                      maxLength: 100,
                      maxLines: 5,
                      cursorColor: const Color(0xFF4186FF),
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFFFFFFFF).withOpacity(0.86),
                        fontWeight: FontWeight.normal,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(0),
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: const Color(0xFFFFFFFF).withOpacity(0.36), fontSize: 12, fontWeight: FontWeight.normal),
                        hintText: "简单描述您的问题……",
                      ),
                      // buildCounter: (
                      //     BuildContext context, {
                      //       @required int currentLength,
                      //       @required int maxLength,
                      //       @required bool isFocused,
                      //     }) {
                      //   return Text.rich(TextSpan(children: [
                      //     TextSpan(
                      //         text: "$currentLength",
                      //         style: TextStyle(color: HydrogenColor.colorWhite36(), fontSize: 12, fontWeight: FontWeight.normal)),
                      //     TextSpan(
                      //         text: '/$maxLength',
                      //         style: TextStyle(color: HydrogenColor.colorWhite36(), fontSize: 12, fontWeight: FontWeight.normal)),
                      //   ]));
                      // },
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                ///操作
                operateBtn(context),
              ],
            )),
      ],
    );
  }

  Widget operateBtn(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 10),
      alignment: Alignment.bottomCenter,
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ///取消按钮
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: 132.5,
                height: 45,
                alignment: Alignment.center,
                decoration:
                    BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(18)), color: const Color(0xFFFFFFFF).withOpacity(0.12)),
                child: Text('取消',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: const Color(0xFFFFFFFF).withOpacity(0.86), fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            ///确认按钮
            GestureDetector(
              onTap: () {
                onSubmit();
              },
              child: Container(
                width: 132.5,
                height: 45,
                alignment: Alignment.center,
                decoration:
                    BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(18)), color: const Color(0xFFFFFFFF).withOpacity(0.12)),
                child: Text('提交',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: const Color(0xFFFFFFFF).withOpacity(0.86), fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onSubmit() async {
    bool storagePermission = await checkStoragePermission();
    if (storagePermission) {
      await zipFile();
    } else {
      Fluttertoast.showToast(msg: "请开启储存权限");
    }
  }

  Future<void> zipFile() async {
    if (editTextController.text.isEmpty) {
      Fluttertoast.showToast(msg: "请输入反馈信息");
      return;
    }
    EasyLoading.show();
    var cacheDir = (await getApplicationCacheDirectory()).path;
    var logDir = (await getExternalCacheDirectories())?[0].path ?? cacheDir;
    XLog.i(LOG_TAG, editTextController.text);
    XLog.flush();
    await Future.delayed(const Duration(milliseconds: 100));
    DateTime now = DateTime.now();
    var zipFileName = '${DateFormat('yyyyMMdd-HHmmss-SSS').format(now)}.zip';
    var zipPath = '${(await getExternalStorageDirectory())?.path}/$zipFileName';

    ZipFileEncoder().zipDirectory(Directory(logDir), filename: zipPath);
    await Future.delayed(const Duration(milliseconds: 1500));
    _uploadLog(zipPath, zipFileName);
  }

  void _uploadLog(String? filePath, String? zipFileName) async {
    UploadPlugin uploadPlugin = UploadPlugin();
    String? token = await uploadPlugin.getQiqiuUploadToken();
    if ((filePath?.isNotEmpty ?? false) && (token?.isNotEmpty ?? false) && File(filePath!).existsSync()) {
      PutOptions options = PutOptions(key: zipFileName);
      bool result = await UploadUtil.uploadFile(filePath!, token!, options: options);
      EasyLoading.dismiss();
      if (result == true) {
        Fluttertoast.showToast(msg: "反馈成功");
        Navigator.of(context).pop();
      }
    } else {
      Fluttertoast.showToast(msg: "反馈失败");
    }
  }

  Future<bool> checkStoragePermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    } else {
      return false;
    }
  }
}
