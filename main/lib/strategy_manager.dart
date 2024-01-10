
import 'dart:convert';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:ncnn_plugin/export.dart';
import 'package:screenshot_plugin/export.dart';
import 'package:yolo_flutter/user_manager.dart';

import 'game_status_manager.dart';
import 'http/httpUtils.dart';
import 'landlord_manager.dart';
import 'overlay_window_widget.dart';

///出牌策略
class StrategyManager {
  static String LOG_TAG = "StrategyManager";
  // static String serverUrl = 'http://172.16.3.225:7070/data';//内网
  static String serverUrl = 'http://216.83.44.19:7070/data';//公网
  static int round = 0;

  static void destroy() {
    round = 0;
  }
  static getLandlordStrategy(GameStatus nextStatus, List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) {
    XLog.i(LOG_TAG, 'request Landlord strategy');
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
    httpParams['action'] = {"position": LandlordManager.myIdentify, "need_play_card": round == 0 ? false : true};
    httpParams['user_id'] = UserManager.deviceId;
    httpParams['round'] = ++round;
    httpParams["player_position"] = LandlordManager.myIdentify;
    httpParams['player_hand_cards'] = myHandCards;
    httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
    var jsonStr = json.encode(httpParams);
    XLog.i(LOG_TAG, 'getServerSuggestion param=$jsonStr');
    var res = await HttpUtils.post(serverUrl, data: jsonStr);
    Map<String, dynamic> resMap = json.decode(res);
    if (resMap.containsKey('action') && resMap['action'] != null && resMap['action'].isNotEmpty) {
      List<int> serverSuggestion = resMap['action'].cast<int>().toList();
      LandlordManager.updateServerSuggestion(serverSuggestion);
    } else {
      if (round > 1) {
        FlutterOverlayWindow.shareData([OverlayUpdateType.suggestion.index, '不出']);
      }
    }
    XLog.i(LOG_TAG, 'getServerSuggestion res=$res');
  }

  static tellServerIDone(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) async {
    List<int>? myOutCards = LandlordManager.getServerCardFormat(GameStatusManager.myOutCardBuff);
    List<int>? myHandCards = LandlordManager.getServerCardFormat(LandlordManager.getMyHandCard(detectList, screenshotModel));
    Map<String, dynamic> httpParams = {};
    httpParams['action'] = {"position": LandlordManager.myIdentify, "play_card": myOutCards, "need_play_card": false};
    httpParams['user_id'] = UserManager.deviceId;
    httpParams['round'] = ++round;
    httpParams["player_position"] = LandlordManager.myIdentify;
    httpParams['player_hand_cards'] = myHandCards;
    httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
    var jsonStr = json.encode(httpParams);
    XLog.i(LOG_TAG, 'tellServerIDone param=$jsonStr');
    var res = HttpUtils.post(serverUrl, data: jsonStr);
    XLog.i(LOG_TAG, 'tellServerIDone res=$res');
  }

  static tellServerISkip(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) async {
    List<int>? myHandCards = LandlordManager.getServerCardFormat(LandlordManager.getMyHandCard(detectList, screenshotModel));
    Map<String, dynamic> httpParams = {};
    httpParams['action'] = {"position": LandlordManager.myIdentify, "play_card": [], "need_play_card": false};
    httpParams['user_id'] = UserManager.deviceId;
    httpParams['round'] = ++round;
    httpParams["player_position"] = LandlordManager.myIdentify;
    httpParams['player_hand_cards'] = myHandCards;
    httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
    var jsonStr = json.encode(httpParams);
    XLog.i(LOG_TAG, 'tellServerISkip param=$jsonStr');
    var res = HttpUtils.post(serverUrl, data: jsonStr);
    XLog.i(LOG_TAG, 'tellServerISkip res=$res');
  }

  static tellServerRightPlayerDone(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) async {
    List<int>? myHandCards = LandlordManager.getServerCardFormat(LandlordManager.getMyHandCard(detectList, screenshotModel));
    List<int>? rightPlayerOutCards = LandlordManager.getServerCardFormat(GameStatusManager.rightOutCardBuff);
    Map<String, dynamic> httpParams = {};
    httpParams['action'] = {"position": LandlordManager.rightPlayerIdentify, "play_card": rightPlayerOutCards, "need_play_card": false};
    httpParams['user_id'] = UserManager.deviceId;
    httpParams['round'] = ++round;
    httpParams['player_hand_cards'] = myHandCards;
    httpParams["player_position"] = LandlordManager.myIdentify;
    httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
    var jsonStr = json.encode(httpParams);
    XLog.i(LOG_TAG, 'tellServerRightPlayerDone param=$jsonStr');
    var res = HttpUtils.post(serverUrl, data: jsonStr);
    XLog.i(LOG_TAG, 'tellServerRightPlayerDone res=$res');
  }

  static tellServerRightPlayerSkip(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) async {
    List<int>? myHandCards = LandlordManager.getServerCardFormat(LandlordManager.getMyHandCard(detectList, screenshotModel));
    Map<String, dynamic> httpParams = {};
    httpParams['action'] = {"position": LandlordManager.rightPlayerIdentify, "play_card": [], "need_play_card": false};
    httpParams['user_id'] = UserManager.deviceId;
    httpParams['round'] = ++round;
    httpParams['player_hand_cards'] = myHandCards;
    httpParams["player_position"] = LandlordManager.myIdentify;
    httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
    var jsonStr = json.encode(httpParams);
    XLog.i(LOG_TAG, 'tellServerRightPlayerSkip param=$jsonStr');
    var res = HttpUtils.post(serverUrl, data: jsonStr);
    XLog.i(LOG_TAG, 'tellServerRightPlayerSkip res=$res');
  }

  static tellServerLeftPlayerDone(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) async {
    List<int>? myHandCards = LandlordManager.getServerCardFormat(LandlordManager.getMyHandCard(detectList, screenshotModel));
    List<int>? leftPlayerOutCards = LandlordManager.getServerCardFormat(GameStatusManager.leftOutCardBuff);
    Map<String, dynamic> httpParams = {};
    httpParams['action'] = {"position": LandlordManager.leftPlayerIdentify, "play_card": leftPlayerOutCards, "need_play_card": false};
    httpParams['user_id'] = UserManager.deviceId;
    httpParams['round'] = ++round;
    httpParams["player_position"] = LandlordManager.myIdentify;
    httpParams['player_hand_cards'] = myHandCards;
    httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
    var jsonStr = json.encode(httpParams);
    XLog.i(LOG_TAG, 'tellServerLeftPlayerDone param=$jsonStr');
    var res = HttpUtils.post(serverUrl, data: jsonStr);
    XLog.i(LOG_TAG, 'tellServerLeftPlayerDone res=$res');
  }

  static tellServerLeftPlayerSkip(List<NcnnDetectModel>? detectList, ScreenshotModel screenshotModel) async {
    List<int>? myHandCards = LandlordManager.getServerCardFormat(LandlordManager.getMyHandCard(detectList, screenshotModel));
    Map<String, dynamic> httpParams = {};
    httpParams['action'] = {"position": LandlordManager.leftPlayerIdentify, "play_card": [], "need_play_card": false};
    httpParams['user_id'] = UserManager.deviceId;
    httpParams['round'] = ++round;
    httpParams["player_position"] = LandlordManager.myIdentify;
    httpParams['player_hand_cards'] = myHandCards;
    httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
    var jsonStr = json.encode(httpParams);
    XLog.i(LOG_TAG, 'tellServerLeftPlayerSkip param=$jsonStr');
    var res = HttpUtils.post(serverUrl, data: jsonStr);
    XLog.i(LOG_TAG, 'tellServerLeftPlayerSkip $res');
  }
}