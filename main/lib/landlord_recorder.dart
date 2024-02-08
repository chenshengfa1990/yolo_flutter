import 'package:flutter/foundation.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:ncnn_plugin/export.dart';
import 'package:yolo_flutter/status/game_status_factory.dart';

import 'overlay_window_widget.dart';

///记牌器
class LandlordRecorder {
  static String LOG_TAG = 'LandlordRecorder';
  static Map<String, int> leftCardMap = {
    "dw": 1,
    "xw": 1,
    "2": 4,
    "A": 4,
    "K": 4,
    "Q": 4,
    "J": 4,
    "10": 4,
    "9": 4,
    "8": 4,
    "7": 4,
    "6": 4,
    "5": 4,
    "4": 4,
    "3": 4
  };

  ///预测剩余牌在谁手上，0: 都不在, 1: 左边玩家, 2: 右边玩家
  static Map<String, int> leftCardInWho = {
    "dw": 0,
    "xw": 0,
    "2": 0,
    "A": 0,
    "K": 0,
    "Q": 0,
    "J": 0,
    "10": 0,
    "9": 0,
    "8": 0,
    "7": 0,
    "6": 0,
    "5": 0,
    "4": 0,
    "3": 0
  };

  static void destroy() {
    XLog.i(LOG_TAG, 'LandlordRecorder destroy');
    leftCardMap = {"dw": 1, "xw": 1, "2": 4, "A": 4, "K": 4, "Q": 4, "J": 4, "10": 4, "9": 4, "8": 4, "7": 4, "6": 4, "5": 4, "4": 4, "3": 4};

    var resetCardNum = {
      "dw": '',
      "xw": '',
      "2": '',
      "A": '',
      "K": '',
      "Q": '',
      "J": '',
      "10": '',
      "9": '',
      "8": '',
      "7": '',
      "6": '',
      "5": '',
      "4": '',
      "3": ''
    };
    for (String key in leftCardInWho.keys) {
      leftCardInWho[key] = 0;
    }
    FlutterOverlayWindow.shareData([OverlayUpdateType.cardRecorder.index, resetCardNum, leftCardInWho]);
  }

  ///预测剩余牌在谁手里
  static int predictLeftCardInWho(String label) {
    List<NcnnDetectModel>? leftHistoryOutCards = GameStatusFactory.getStatusManager().leftHistoryOutCard;
    List<NcnnDetectModel>? rightHistoryOutCards = GameStatusFactory.getStatusManager().rightHistoryOutCard;
    int leftOutNum = 0; //左边玩家打过这张牌的数量
    int rightOutNum = 0; //右边玩家打过这张牌的数量
    for (var model in leftHistoryOutCards) {
      if (model.label == label) {
        leftOutNum++;
      }
    }
    for (var model in rightHistoryOutCards) {
      if (model.label == label) {
        rightOutNum++;
      }
    }
    if (leftOutNum > rightOutNum) {
      return 2;
    } else if (rightOutNum > leftOutNum) {
      return 1;
    }
    return 0;
  }

  static void updateRecorder(List<NcnnDetectModel>? detectModels) {
    if (detectModels == null) {
      return;
    }
    for (var model in detectModels) {
      if (leftCardMap.containsKey(model.label)) {
        int leftNum = leftCardMap[model.label]! - 1;
        if (kReleaseMode && leftNum < 0) {
          XLog.e(LOG_TAG, 'Card recorder label ${model.label} leftNum is $leftNum, less than 0, set to 0');
          leftNum = 0;
        }
        leftCardMap[model.label!] = leftNum;
        if (leftNum == 1) {
          leftCardInWho[model.label!] = predictLeftCardInWho(model.label!);
        } else {
          leftCardInWho[model.label!] = 0;
        }
      }
    }
    XLog.i(LOG_TAG, 'Latest card recorder: $leftCardMap');
    FlutterOverlayWindow.shareData([OverlayUpdateType.cardRecorder.index, leftCardMap, leftCardInWho]);
  }
}