import 'dart:async';
import 'dart:io';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:ncnn_plugin/export.dart';
import 'package:screenshot_plugin/export.dart';
import 'package:yolo_flutter/landlord/landlord_type.dart';
import 'package:yolo_flutter/landlord_recorder.dart';
import 'package:yolo_flutter/status/game_status_weile.dart';
import 'package:yolo_flutter/strategy_manager.dart';
import 'package:yolo_flutter/util/FileUtil.dart';

import '../status/game_status_manager.dart';
import '../landlord/landlord_manager.dart';
import '../overlay_window_widget.dart';

abstract class ScreenShotManager {
  static const String LOG_TAG = 'ScreenShotManager';
  late ScreenshotPlugin screenshotPlugin;
  late NcnnPlugin ncnnPlugin;
  static double width = 0;
  static double height = 0;
  int screenShotCount = 0;
  int detectCount = 0;
  bool isGameRunning = false;
  bool firstCheck = true;

  ScreenShotManager(this.ncnnPlugin) {
    screenshotPlugin = ScreenshotPlugin();
  }

  Future<bool?> requestPermission() async {
    return await screenshotPlugin.requestPermission();
  }

  Future<void> startScreenShot();

  void startScreenshotRepeat() async {
    isGameRunning = true;
    while (isGameRunning) {
      await startScreenShot();
    }
  }

  void notifyOverlayWindow(OverlayUpdateType updateType, {List<NcnnDetectModel>? models, String? showString}) {
    String showStr = (models != null ? LandlordManager.getCardsSorted(models) : showString) ?? '';
    FlutterOverlayWindow.shareData([updateType.index, showStr]);
  }

  void destroy() {
    isGameRunning = false;
    screenshotPlugin.stopScreenshot();
    screenShotCount = 0;
    detectCount = 0;
    firstCheck = true;
  }
}
