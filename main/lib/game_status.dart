import 'package:ncnn_plugin/export.dart';
import 'package:screenshot_plugin/export.dart';
import 'package:yolo_flutter/region_manager.dart';

import 'landlord_manager.dart';

enum GameStatus {
  gamePreparing, // 游戏准备中
  gameReady, //游戏准备好, 地主已分配

  myTurn, //轮到我出牌，我的出牌按钮出现
  iSkip, //我跳过，不出牌
  iDone, //我已出牌

  rightTurn, //轮到右边玩家出牌
  rightSkip, //右边玩家跳过，不出牌
  rightDone, //右边玩家已出牌

  leftTurn, //轮到左边玩家出牌
  leftSkip, //左边玩家跳过，不出牌
  leftDone, //左边玩家已出牌

  gameOver, //游戏结束
}


///状态管理
class GameStatusManager {
  static GameStatus curGameStatus = GameStatus.gamePreparing;
  static List<String> gameStatusStr = ['准备中', '地主已分配', '我出牌中', '我不出', '我已出牌', '下家出牌中', '下家不出', '下家已出牌', '上家出牌中', '上家不出', '上家已出牌', '游戏结束'];

  static GameStatus initGameStatus(NcnnDetectModel landlord, ScreenshotModel screenshotModel) {
    curGameStatus = GameStatus.gamePreparing;
    if (RegionManager.inMyLandlordRegion(landlord, screenshotModel)) {
      curGameStatus = GameStatus.myTurn;
    } else if (RegionManager.inLeftPlayerLandlordRegion(landlord, screenshotModel)) {
      curGameStatus = GameStatus.leftTurn;
    } else if (RegionManager.inRightPlayerLandlordRegion(landlord, screenshotModel)) {
      curGameStatus = GameStatus.rightTurn;
    }
    return curGameStatus;
  }

  static String getGameStatusStr(GameStatus status) {
    return gameStatusStr[status.index];
  }

  static GameStatus calculateNextGameStatus(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) {
    GameStatus nextStatus = curGameStatus;
    if (LandlordManager.getChuPai(detectList, screenshotModel) != null) {
      print('chenshengfa chupai');
      nextStatus = GameStatus.myTurn;
      return nextStatus;
    }
    switch (curGameStatus) {
      case GameStatus.myTurn:
        var buchu = LandlordManager.getBuChu(detectList, screenshotModel);
        if (RegionManager.inMyBuchuRegion(buchu, screenshotModel)) {
          print('chenshengfa iSkip');
          nextStatus = GameStatus.iSkip;
        } else {
          var myOutCard = LandlordManager.getMyOutCard(detectList, screenshotModel);
          if (myOutCard?.isNotEmpty ?? false) {
            print('chenshengfa iDone');
            nextStatus = GameStatus.iDone;
          }
        }
        break;
      case GameStatus.iSkip:
        print('chenshengfa skip toRightTurn');
        nextStatus = GameStatus.rightTurn;
        break;
      case GameStatus.iDone:
        print('chenshengfa done to rightTurn');
        nextStatus = GameStatus.rightTurn;
        break;
      case GameStatus.rightTurn:
        var buchu = LandlordManager.getBuChu(detectList, screenshotModel);
        if (RegionManager.inRightBuchuRegion(buchu, screenshotModel)) {
          print('chenshengfa rightSkip');
          nextStatus = GameStatus.rightSkip;
        } else {
          var rightOutCard = LandlordManager.getRightPlayerOutCard(detectList, screenshotModel);
          if (rightOutCard?.isNotEmpty ?? false) {
            print('chenshengfa rightDone');
            nextStatus = GameStatus.rightDone;
          }
        }
        break;
      case GameStatus.rightSkip:
        print('chenshengfa rightSkip to leftTurn');
        nextStatus = GameStatus.leftTurn;
        break;
      case GameStatus.rightDone:
        print('chenshengfa rightDone to leftTurn');
        nextStatus = GameStatus.leftTurn;
        break;
      case GameStatus.leftTurn:
        var buchu = LandlordManager.getBuChu(detectList, screenshotModel);
        if (RegionManager.inLeftBuchuRegion(buchu, screenshotModel)) {
          print('chenshengfa leftSkip');
          nextStatus = GameStatus.leftSkip;
        } else {
          var leftOutCard = LandlordManager.getLeftPlayerOutCard(detectList, screenshotModel);
          if (leftOutCard?.isNotEmpty ?? false) {
            print('chenshengfa leftDone, ');
            nextStatus = GameStatus.leftDone;
          }
        }
        break;
      case GameStatus.leftSkip:
        print('chenshengfa leftSkip to myTurn');
        nextStatus = GameStatus.myTurn;
        break;
      case GameStatus.leftDone:
        print('chenshengfa leftDone to myTurn');
        nextStatus = GameStatus.myTurn;
        break;
    }
    return nextStatus;
  }
}