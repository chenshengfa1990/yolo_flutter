
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:ncnn_plugin/export.dart';

import 'overlay_window_widget.dart';

///记牌器
class LandlordRecorder {
  static String LOG_TAG = 'LandlordRecorder';
  static Map<String, int> leftCardMap = {"dw": 1, "xw": 1, "2": 4, "A": 4, "K": 4, "Q": 4, "J": 4, "10": 4, "9": 4, "8": 4, "7": 4, "6": 4, "5": 4, "4": 4, "3": 4};

  static void destroy() {
    leftCardMap = {"dw": 1, "xw": 1, "2": 4, "A": 4, "K": 4, "Q": 4, "J": 4, "10": 4, "9": 4, "8": 4, "7": 4, "6": 4, "5": 4, "4": 4, "3": 4};

    var resetCardNum = {"dw": '', "xw": '', "2": '', "A": '', "K": '', "Q": '', "J": '', "10": '', "9": '', "8": '', "7": '', "6": '', "5": '', "4": '', "3": ''};
    FlutterOverlayWindow.shareData([OverlayUpdateType.cardRecorder.index, resetCardNum]);
  }

  static void updateRecorder(List<NcnnDetectModel>? detectModels) {
    if (detectModels == null) {
      return;
    }
    for(var model in detectModels) {
      if (leftCardMap.containsKey(model.label)) {
        int leftNum = leftCardMap[model.label]! - 1;
        leftCardMap[model.label!] = leftNum;
      }
    }
    XLog.i(LOG_TAG, 'Latest card recorder: $leftCardMap');
    FlutterOverlayWindow.shareData([OverlayUpdateType.cardRecorder.index, leftCardMap]);
  }
}