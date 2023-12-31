
import 'dart:convert';

import 'package:ncnn_plugin/export.dart';
import 'package:screenshot_plugin/export.dart';

import 'game_status.dart';
import 'http/httpUtils.dart';
import 'landlord_manager.dart';

///出牌策略
class StrategyManager {
  static int round = 0;
  static getLandlordStrategy(GameStatus nextStatus, List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) {
    if (nextStatus == GameStatus.myTurn) {
      getServerSuggestion(detectList, screenshotModel);
    } else if (nextStatus == GameStatus.iDone) {
      tellServerIDone(detectList, screenshotModel);
    } else if (nextStatus == GameStatus.rightDone) {
      tellServerRightPlayerDone(detectList, screenshotModel);
    } else if (nextStatus == GameStatus.leftDone) {
      tellServerLeftPlayerDone(detectList, screenshotModel);
    }
  }

  static getServerSuggestion(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) async {
    List<int>? myHandCards = LandlordManager.getServerCardFormat(LandlordManager.getMyHandCard(detectList, screenshotModel));
    Map<String, dynamic> httpParams = {};
    httpParams['action'] = {"position": LandlordManager.myIdentify, "need_play_card": true};
    httpParams['user_id'] = 123;
    httpParams['round'] = round++;
    httpParams["player_position"] = LandlordManager.myIdentify;
    httpParams['player_hand_cards'] = myHandCards;
    // httpParams['three_landlord_cards'] = [17, 17, 1];
    var jsonStr = json.encode(httpParams);
    var res = await HttpUtils.post('http://172.16.3.225:7070/data', data: jsonStr);
    print(res);
  }

  static tellServerIDone(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) async {
    List<int>? myOutCards = LandlordManager.getServerCardFormat(LandlordManager.getMyOutCard(detectList, screenshotModel));
    Map<String, dynamic> httpParams = {};
    httpParams['action'] = {"position": LandlordManager.myIdentify, "play_card": myOutCards, "need_play_card": false};
    httpParams['user_id'] = 123;
    httpParams['round'] = round++;
    httpParams["player_position"] = LandlordManager.myIdentify;
    var jsonStr = json.encode(httpParams);
    HttpUtils.post('http://172.16.3.225:7070/data', data: jsonStr);
  }

  static tellServerRightPlayerDone(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) async {
    List<int>? rightPlayerOutCards = LandlordManager.getServerCardFormat(LandlordManager.getRightPlayerOutCard(detectList, screenshotModel));
    Map<String, dynamic> httpParams = {};
    httpParams['action'] = {"position": LandlordManager.rightPlayerIdentify, "play_card": rightPlayerOutCards, "need_play_card": false};
    httpParams['user_id'] = 123;
    httpParams['round'] = round++;
    httpParams["player_position"] = LandlordManager.myIdentify;
    var jsonStr = json.encode(httpParams);
    HttpUtils.post('http://172.16.3.225:7070/data', data: jsonStr);
  }

  static tellServerLeftPlayerDone(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) async {
    List<int>? leftPlayerOutCards = LandlordManager.getServerCardFormat(LandlordManager.getLeftPlayerOutCard(detectList, screenshotModel));
    Map<String, dynamic> httpParams = {};
    httpParams['action'] = {"position": LandlordManager.leftPlayerIdentify, "play_card": leftPlayerOutCards, "need_play_card": false};
    httpParams['user_id'] = 123;
    httpParams['round'] = round++;
    httpParams["player_position"] = LandlordManager.myIdentify;
    var jsonStr = json.encode(httpParams);
    HttpUtils.post('http://172.16.3.225:7070/data', data: jsonStr);
  }
}