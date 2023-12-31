

import 'package:ncnn_plugin/ncnn_detect_model.dart';
import 'package:screenshot_plugin/export.dart';

import 'region_manager.dart';

class LandlordManager {

  ///纸牌按人类思维的排序顺序
  static Map<String, int> labelIndex = {"dw": 0, "xw": 1, "2": 2, "A": 3, "K": 4, "Q": 5, "J": 6, "10": 7, "9": 8, "8": 9, "7": 10, "6": 11, "5": 12, "4": 13, "3": 14};

  ///后台需要的纸牌对应的数字
  static Map<String, int> labelServerIndex = {"dw": 30, "xw": 20, "2": 17, "A": 14, "K": 13, "Q": 12, "J": 11, "10": 10, "9": 9, "8": 8, "7": 7, "6": 6, "5": 5, "4": 4, "3": 3};
  ///W表示大王，w表示小王
  static List<String> showName = ["W", "w", "2", "A", "K", "Q", "J", "10", "9", "8", "7", "6", "5", "4", "3"];

  ///玩家身份
  static String myIdentify = "";
  static String leftPlayerIdentify = "";
  static String rightPlayerIdentify = "";

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
    return resList;
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
  
  ///获取是否检测到地主，地主出现表示准备好
  static NcnnDetectModel? getLandlord(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) {
    try {
      return detectList?.firstWhere((element) => element.label == 'dizhu');
    } catch (e) {
      return null;
    }
  }

  static NcnnDetectModel? getChuPai(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) {
    try {
      return detectList?.firstWhere((element) => element.label == 'chupai');
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
      myIdentify = "landlord";
      rightPlayerIdentify = "landlord_down";
      leftPlayerIdentify = "landlord_up";
    } else if (RegionManager.inLeftPlayerLandlordRegion(landlord, screenshotModel)) {
      leftPlayerIdentify = "landlord";
      myIdentify = "landlord_down";
      rightPlayerIdentify = "landlord_up";
    } else if (RegionManager.inRightPlayerLandlordRegion(landlord, screenshotModel)) {
      rightPlayerIdentify = "landlord";
      myIdentify = "landlord_up";
      leftPlayerIdentify = "landlord_down";
    }
  }
}