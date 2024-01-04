
import 'dart:convert';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:ncnn_plugin/export.dart';
import 'package:screenshot_plugin/export.dart';

import 'game_status_manager.dart';
import 'http/httpUtils.dart';
import 'landlord_manager.dart';

///出牌策略
class StrategyManager {
  static int round = 0;

  static void destroy() {
    round = 0;
  }
  static getLandlordStrategy(GameStatus nextStatus, List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) {
    if (nextStatus == GameStatus.myTurn) {
      getServerSuggestion(detectList, screenshotModel);
    } else if (nextStatus == GameStatus.iDone) {
      tellServerIDone(detectList, screenshotModel);
    } else if (nextStatus == GameStatus.iSkip) {
      tellServerISkip(detectList, screenshotModel);
    } else if (nextStatus == GameStatus.rightDone) {
      tellServerRightPlayerDone(detectList, screenshotModel);
    } else if (nextStatus == GameStatus.rightSkip) {
      tellServerRightPlayerSkip(detectList, screenshotModel);
    } else if (nextStatus == GameStatus.leftDone) {
      tellServerLeftPlayerDone(detectList, screenshotModel);
    } else if (nextStatus == GameStatus.leftSkip) {
      tellServerLeftPlayerSkip(detectList, screenshotModel);
    }
  }

  static getServerSuggestion(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) async {
    List<int>? myHandCards = LandlordManager.getServerCardFormat(LandlordManager.getMyHandCard(detectList, screenshotModel));
    Map<String, dynamic> httpParams = {};
    httpParams['num_cards_left_dict'] = {"landlord": 20, "landlord_down": 17,"landlord_up": 17};
    httpParams['action'] = {"position": LandlordManager.myIdentify, "need_play_card": round == 0 ? false : true};
    httpParams['user_id'] = 123;
    httpParams['round'] = ++round;
    httpParams["player_position"] = LandlordManager.myIdentify;
    httpParams['player_hand_cards'] = myHandCards;
    httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
    var jsonStr = json.encode(httpParams);
    var res = await HttpUtils.post('http://172.16.3.225:7070/data', data: jsonStr);
    Map<String, dynamic> resMap = json.decode(res);
    if (resMap.containsKey('action') && resMap['action'] != null && resMap['action'].isNotEmpty) {
      List<int> serverSuggestion = resMap['action'].cast<int>().toList();
      LandlordManager.updateServerSuggestion(serverSuggestion);
      // await FlutterOverlayWindow.shareData(suggestion);
    }
    print('getServerSuggestion $res');
  }

  static tellServerIDone(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) async {
    List<int>? myOutCards = LandlordManager.getServerCardFormat(LandlordManager.getMyOutCard(detectList, screenshotModel));
    List<int>? myHandCards = LandlordManager.getServerCardFormat(LandlordManager.getMyHandCard(detectList, screenshotModel));
    Map<String, dynamic> httpParams = {};
    httpParams['num_cards_left_dict'] = {"landlord": 20, "landlord_down": 17,"landlord_up": 17};
    httpParams['action'] = {"position": LandlordManager.myIdentify, "play_card": myOutCards, "need_play_card": false};
    httpParams['user_id'] = 123;
    httpParams['round'] = ++round;
    httpParams["player_position"] = LandlordManager.myIdentify;
    httpParams['player_hand_cards'] = myHandCards;
    httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
    var jsonStr = json.encode(httpParams);
    var res = HttpUtils.post('http://172.16.3.225:7070/data', data: jsonStr);
    print('tellServerIDone $res');
  }

  static tellServerISkip(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) async {
    List<int>? myHandCards = LandlordManager.getServerCardFormat(LandlordManager.getMyHandCard(detectList, screenshotModel));
    Map<String, dynamic> httpParams = {};
    httpParams['num_cards_left_dict'] = {"landlord": 20, "landlord_down": 17,"landlord_up": 17};
    httpParams['action'] = {"position": LandlordManager.myIdentify, "play_card": [], "need_play_card": false};
    httpParams['user_id'] = 123;
    httpParams['round'] = ++round;
    httpParams["player_position"] = LandlordManager.myIdentify;
    httpParams['player_hand_cards'] = myHandCards;
    httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
    var jsonStr = json.encode(httpParams);
    var res = HttpUtils.post('http://172.16.3.225:7070/data', data: jsonStr);
    print('tellServerISkip $res');
  }

  static tellServerRightPlayerDone(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) async {
    List<int>? myHandCards = LandlordManager.getServerCardFormat(LandlordManager.getMyHandCard(detectList, screenshotModel));
    List<int>? rightPlayerOutCards = LandlordManager.getServerCardFormat(LandlordManager.getRightPlayerOutCard(detectList, screenshotModel));
    Map<String, dynamic> httpParams = {};
    httpParams['num_cards_left_dict'] = {"landlord": 20, "landlord_down": 17,"landlord_up": 17};
    httpParams['action'] = {"position": LandlordManager.rightPlayerIdentify, "play_card": rightPlayerOutCards, "need_play_card": false};
    httpParams['user_id'] = 123;
    httpParams['round'] = ++round;
    httpParams['player_hand_cards'] = myHandCards;
    httpParams["player_position"] = LandlordManager.myIdentify;
    httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
    var jsonStr = json.encode(httpParams);
    var res = HttpUtils.post('http://172.16.3.225:7070/data', data: jsonStr);
    print('tellServerRightPlayerDone $res');
  }

  static tellServerRightPlayerSkip(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) async {
    List<int>? myHandCards = LandlordManager.getServerCardFormat(LandlordManager.getMyHandCard(detectList, screenshotModel));
    Map<String, dynamic> httpParams = {};
    httpParams['num_cards_left_dict'] = {"landlord": 20, "landlord_down": 17,"landlord_up": 17};
    httpParams['action'] = {"position": LandlordManager.rightPlayerIdentify, "play_card": [], "need_play_card": false};
    httpParams['user_id'] = 123;
    httpParams['round'] = ++round;
    httpParams['player_hand_cards'] = myHandCards;
    httpParams["player_position"] = LandlordManager.myIdentify;
    httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
    var jsonStr = json.encode(httpParams);
    var res = HttpUtils.post('http://172.16.3.225:7070/data', data: jsonStr);
    print('tellServerRightPlayerSkip $res');
  }

  static tellServerLeftPlayerDone(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) async {
    List<int>? myHandCards = LandlordManager.getServerCardFormat(LandlordManager.getMyHandCard(detectList, screenshotModel));
    List<int>? leftPlayerOutCards = LandlordManager.getServerCardFormat(LandlordManager.getLeftPlayerOutCard(detectList, screenshotModel));
    Map<String, dynamic> httpParams = {};
    httpParams['num_cards_left_dict'] = {"landlord": 20, "landlord_down": 17,"landlord_up": 17};
    httpParams['action'] = {"position": LandlordManager.leftPlayerIdentify, "play_card": leftPlayerOutCards, "need_play_card": false};
    httpParams['user_id'] = 123;
    httpParams['round'] = ++round;
    httpParams["player_position"] = LandlordManager.myIdentify;
    httpParams['player_hand_cards'] = myHandCards;
    httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
    var jsonStr = json.encode(httpParams);
    var res = HttpUtils.post('http://172.16.3.225:7070/data', data: jsonStr);
    print('tellServerLeftPlayerDone $res');
  }

  static tellServerLeftPlayerSkip(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) async {
    List<int>? myHandCards = LandlordManager.getServerCardFormat(LandlordManager.getMyHandCard(detectList, screenshotModel));
    Map<String, dynamic> httpParams = {};
    httpParams['num_cards_left_dict'] = {"landlord": 20, "landlord_down": 17,"landlord_up": 17};
    httpParams['action'] = {"position": LandlordManager.leftPlayerIdentify, "play_card": [], "need_play_card": false};
    httpParams['user_id'] = 123;
    httpParams['round'] = ++round;
    httpParams["player_position"] = LandlordManager.myIdentify;
    httpParams['player_hand_cards'] = myHandCards;
    httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
    var jsonStr = json.encode(httpParams);
    var res = HttpUtils.post('http://172.16.3.225:7070/data', data: jsonStr);
    print('tellServerLeftPlayerSkip $res');
  }
}