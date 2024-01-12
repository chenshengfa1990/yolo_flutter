

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:ncnn_plugin/ncnn_detect_model.dart';
import 'package:screenshot_plugin/export.dart';

import 'overlay_window_widget.dart';
import 'region_manager.dart';

class LandlordManager {
  static String LOG_TAG = 'LandlordManager';

  ///纸牌按人类思维的排序顺序
  static Map<String, int> labelIndex = {
    "dw": 0,
    "xw": 1,
    "2": 2,
    "A": 3,
    "K": 4,
    "Q": 5,
    "J": 6,
    "10": 7,
    "9": 8,
    "8": 9,
    "7": 10,
    "6": 11,
    "5": 12,
    "4": 13,
    "3": 14
  };

  ///后台需要的纸牌对应的数字
  static Map<String, int> labelServerIndex = {
    "dw": 30,
    "xw": 20,
    "2": 17,
    "A": 14,
    "K": 13,
    "Q": 12,
    "J": 11,
    "10": 10,
    "9": 9,
    "8": 8,
    "7": 7,
    "6": 6,
    "5": 5,
    "4": 4,
    "3": 3
  };

  static Map<int, String> serverIndexToCard = {
    30: "W",
    20: "w",
    17: "2",
    14: "A",
    13: "K",
    12: "Q",
    11: "J",
    10: "10",
    9: "9",
    8: "8",
    7: "7",
    6: "6",
    5: "5",
    4: "4",
    3: "3"
  };

  ///W表示大王，w表示小王
  static List<String> showName = ["W", "w", "2", "A", "K", "Q", "J", "10", "9", "8", "7", "6", "5", "4", "3"];

  ///地主额外三张牌
  static List<NcnnDetectModel>? threeCards;
  static String threeCardStr = '';
  static List<int>? threeCardInt;

  ///传给后台
  static List<int>? myHandCardServerFormat;

  ///玩家身份, "landlord", "landlord_down", "landlord_up"
  static String myIdentify = "";
  static String leftPlayerIdentify = "";
  static String rightPlayerIdentify = "";

  ///剩余牌数
  static int myLeftCards = 0;
  static int leftPlayerLeftCards = 0;
  static int rightPlayerLeftCards = 0;

  static String serverSuggestion = '';

  static void destroy() {
    myIdentify = "";
    leftPlayerIdentify = "";
    rightPlayerIdentify = "";
    threeCardStr = "";
    threeCards = null;
    threeCardInt = null;
    serverSuggestion = '';
    FlutterOverlayWindow.shareData([OverlayUpdateType.threeCard.index, threeCardStr]);
    FlutterOverlayWindow.shareData([OverlayUpdateType.leftOutCard.index, '']);
    FlutterOverlayWindow.shareData([OverlayUpdateType.rightOutCard.index, '']);
    FlutterOverlayWindow.shareData([OverlayUpdateType.myOutCard.index, '']);
    FlutterOverlayWindow.shareData([OverlayUpdateType.handCard.index, '']);
    FlutterOverlayWindow.shareData([OverlayUpdateType.suggestion.index, '']);

  }

  ///对牌进行排列
  static String getCardsSorted(List<NcnnDetectModel>? detectModels) {
    List<int> sortedList = [];
    void insertSorted(int value) {
      int insertionIndex = -1;
      for (int i = 0; i < sortedList.length; i++) {
        if (value < sortedList[i]) {
          insertionIndex = i;
          break;
        }
      }
      if (insertionIndex == -1) {
        sortedList.add(value);
      } else {
        sortedList.insert(insertionIndex, value);
      }
    }

    detectModels?.forEach((model) {
      if (labelIndex.containsKey(model.label)) {
        int index = labelIndex[model.label]!;
        insertSorted(index);
      }
    });
    String resStr = "";
    for (int i = 0; i < sortedList.length; i++) {
      resStr = '$resStr${showName[sortedList[i]]}';
    }
    return resStr;
  }

  ///获取后台需要的牌的格式
  static List<int>? getServerCardFormat(List<NcnnDetectModel>? detectModels) {
    List<int> cardList = [];
    detectModels?.forEach((element) {
      cardList.add(labelServerIndex[element.label]!);
    });
    if (cardList.isEmpty) {
      return null;
    }
    return cardList;
  }

  static void updateServerSuggestion(List<int> suggestion) {
    String res = '';
    for (var element in suggestion) {
      res = '$res${serverIndexToCard[element]}';
    }
    serverSuggestion = res;
    FlutterOverlayWindow.shareData([OverlayUpdateType.suggestion.index, serverSuggestion]);
  }

  static List<NcnnDetectModel>? sortedByXPos(List<NcnnDetectModel>? detectModels) {
    List<NcnnDetectModel> sortedList = [];
    void insertSorted(NcnnDetectModel value) {
      int insertionIndex = -1;
      for (int i = 0; i < sortedList.length; i++) {
        if (value.x! < sortedList[i].x!) {
          insertionIndex = i;
          break;
        }
      }
      if (insertionIndex == -1) {
        sortedList.add(value);
      } else {
        sortedList.insert(insertionIndex, value);
      }
    }

    detectModels?.forEach((model) {
      if (labelIndex.containsKey(model.label)) {
        insertSorted(model);
      }
    });
    if (sortedList.isNotEmpty) {
      return sortedList;
    }
    return null;
  }

  ///获取地主3张牌
  static List<NcnnDetectModel>? getThreeCard(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) {
    List<NcnnDetectModel> resList = [];
    detectList?.forEach((element) {
      if (RegionManager.inThreeCardRegion(element, screenshotModel)) {
        if (labelIndex.containsKey(element.label)) {
          resList.add(element);
        }
      }
    });
    List<NcnnDetectModel>? sortedModels = sortedByXPos(resList);
    if (sortedModels?.isNotEmpty ?? false) {
      if (sortedModels!.length >= 3) {
        var models = sortedModels.sublist(sortedModels.length - 3);
        threeCards = models;
        threeCardStr = getCardsSorted(threeCards);
        threeCardInt = getServerCardFormat(threeCards);
        return models;
      } else {
        XLog.i(LOG_TAG, 'sortedModels length is ${sortedModels.length}');
      }
    } else {
      XLog.i(LOG_TAG, 'sortedModels is null');
    }
    return null;
  }

  ///获取我的手牌
  static List<NcnnDetectModel>? getMyHandCard(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) {
    List<NcnnDetectModel> resList = [];
    detectList?.forEach((element) {
      if (RegionManager.inMyHandCardRegion(element, screenshotModel)) {
        if (labelIndex.containsKey(element.label)) {
          resList.add(element);
        }
      }
    });
    myHandCardServerFormat = getServerCardFormat(resList);
    return resList;
  }

  ///获取我的出牌
  static List<NcnnDetectModel>? getMyOutCard(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) {
    List<NcnnDetectModel> resList = [];
    detectList?.forEach((element) {
      if (RegionManager.inMyOutCardRegion(element, screenshotModel)) {
        if (labelIndex.containsKey(element.label)) {
          resList.add(element);
        }
      }
    });
    return resList;
  }

  ///更新我自己剩余牌数
  static updateMyLeftCards(List<NcnnDetectModel>? myOutCards) {
    myLeftCards = myLeftCards - (myOutCards?.length ?? 0);
  }

  ///获取左边玩家出牌
  static List<NcnnDetectModel>? getLeftPlayerOutCard(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) {
    List<NcnnDetectModel> resList = [];
    detectList?.forEach((element) {
      if (RegionManager.inLeftPlayerOutCardRegion(element, screenshotModel)) {
        if (labelIndex.containsKey(element.label)) {
          resList.add(element);
        }
      }
    });
    return resList;
  }

  ///更新左边玩家剩余牌数
  static updateLeftPlayerLeftCards(List<NcnnDetectModel>? leftPlayerOutCards) {
    leftPlayerLeftCards = leftPlayerLeftCards - (leftPlayerOutCards?.length ?? 0);
  }

  ///获取右边玩家出牌
  static List<NcnnDetectModel>? getRightPlayerOutCard(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) {
    List<NcnnDetectModel> resList = [];
    detectList?.forEach((element) {
      if (RegionManager.inRightPlayerOutCardRegion(element, screenshotModel)) {
        if (labelIndex.containsKey(element.label)) {
          resList.add(element);
        }
      }
    });
    return resList;
  }

  ///更新右边玩家剩余牌数
  static updateRightPlayerLeftCards(List<NcnnDetectModel>? rightPlayerOutCards) {
    rightPlayerLeftCards = rightPlayerLeftCards - (rightPlayerOutCards?.length ?? 0);
  }
  
  ///获取是否检测到地主，地主出现表示准备好
  static NcnnDetectModel? getLandlord(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) {
    try {
      return detectList?.firstWhere((element) => element.label == 'dizhu');
    } catch (e) {
      return null;
    }
  }

  ///出牌
  static NcnnDetectModel? getChuPai(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) {
    try {
      return detectList?.firstWhere((element) => (element.label == 'chupai'));
    } catch (e) {
      return null;
    }
  }

  ///要不起
  static NcnnDetectModel? getYaobuqi(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) {
    try {
      return detectList?.firstWhere((element) => element.label == 'yaobuqi');
    } catch (e) {
      return null;
    }
  }

  static List<NcnnDetectModel>? getBuChu(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) {
    List<NcnnDetectModel> buchuRes = [];
    for (int i = 0; i < (detectList?.length ?? 0); i++) {
      if (detectList![i].label == 'buchu') {
        buchuRes.add(detectList[i]);
      }
    }
    if (buchuRes.isEmpty) {
      return null;
    }
    return buchuRes;
  }

  static void initPlayerIdentify(NcnnDetectModel landlord, ScreenshotModel screenshotModel) {
    if (RegionManager.inMyLandlordRegion(landlord, screenshotModel)) {
      XLog.i(LOG_TAG, 'I am landlord');
      myIdentify = "landlord";
      rightPlayerIdentify = "landlord_down";
      leftPlayerIdentify = "landlord_up";
      myLeftCards = 20;
      leftPlayerLeftCards = 17;
      rightPlayerLeftCards = 17;
    } else if (RegionManager.inLeftPlayerLandlordRegion(landlord, screenshotModel)) {
      XLog.i(LOG_TAG, 'LeftPlayer is landlord');
      leftPlayerIdentify = "landlord";
      myIdentify = "landlord_down";
      rightPlayerIdentify = "landlord_up";
      myLeftCards = 17;
      leftPlayerLeftCards = 20;
      rightPlayerLeftCards = 17;
    } else if (RegionManager.inRightPlayerLandlordRegion(landlord, screenshotModel)) {
      XLog.i(LOG_TAG, 'RightPlayer is landlord');
      rightPlayerIdentify = "landlord";
      myIdentify = "landlord_up";
      leftPlayerIdentify = "landlord_down";
      myLeftCards = 17;
      leftPlayerLeftCards = 17;
      rightPlayerLeftCards = 20;
    }
  }
}