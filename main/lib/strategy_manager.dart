import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:ncnn_plugin/export.dart';
import 'package:screenshot_plugin/export.dart';
import 'package:yolo_flutter/user_manager.dart';

import 'status/game_status_factory.dart';
import 'status/sub/game_status_huanle.dart';
import 'http/httpUtils.dart';
import 'landlord/landlord_manager.dart';
import 'landlord_recorder.dart';
import 'overlay_window_widget.dart';
import 'status/game_status_manager.dart';

enum RequestTurn {
  myTurn,
  leftTurn,
  rightTurn,
}

///出牌策略
class StrategyManager {
  static String LOG_TAG = "StrategyManager";

  // static String serverUrl = 'http://172.16.3.225:7070/data';//内网
  // static String serverUrl = 'http://216.83.44.19:7070/data'; //公网
  // static String serverUrl = 'https://ead8-14-145-204-91.ngrok-free.app/data'; //公网
  // static String userInfoUrl = 'https://ead8-14-145-204-91.ngrok-free.app/self';//用户信息
  static String serverUrl = 'http://alidouapi.xxrz.top/data'; //公网
  static String userInfoUrl = 'http://alidouapi.xxrz.top/self'; //用户信息
  static int round = 0;
  static RequestTurn? currentTurn;
  late GameStatusManager statusManager;

  static final StrategyManager _singleton = StrategyManager._internal();

  factory StrategyManager() {
    return _singleton;
  }

  StrategyManager._internal() {
    statusManager = GameStatusFactory.getStatusManager();
  }

  void destroy() {
    round = 0;
    currentTurn = null;
  }

  void notifyOverlayWindow(OverlayUpdateType updateType, {List<NcnnDetectModel>? models, String? showString}) {
    String showStr = (models != null ? LandlordManager.getCardsSorted(models) : showString) ?? '';
    FlutterOverlayWindow.shareData([updateType.index, showStr]);
  }

  Future<void> triggerNext() async {
    XLog.i(LOG_TAG, 'currentRequestTurn: $currentTurn');
    if (currentTurn == RequestTurn.myTurn) {
      if (statusManager.myBuChu == true) {
        statusManager.myBuChu = false;
        await tellServerISkip();
      } else {
        if (statusManager.myOutCardBuffLength != 3) {
          return;
        }
        await tellServerIDone();
      }
      currentTurn = RequestTurn.rightTurn;
      XLog.i(LOG_TAG, 'myTurn request, triggerNext');
      await triggerNext();
    } else if (currentTurn == RequestTurn.rightTurn) {
      if (statusManager.rightBuChu == true) {
        statusManager.rightBuChu = false;
        await tellServerRightPlayerSkip();
      } else {
        if (statusManager.rightOutCardBuffLength != 4) {
          return;
        }
        await tellServerRightPlayerDone();
      }
      currentTurn = RequestTurn.leftTurn;
      XLog.i(LOG_TAG, 'rightTurn request, triggerNext');
      await triggerNext();
    } else if (currentTurn == RequestTurn.leftTurn) {
      if (statusManager.leftBuChu == true) {
        statusManager.leftBuChu = false;
        await tellServerLeftPlayerSkip();
        await getServerSuggestion();
      } else {
        if (statusManager.leftOutCardBuffLength != 4) {
          return;
        }
        await tellServerLeftPlayerDone();
        await getServerSuggestion();
      }
      currentTurn = RequestTurn.myTurn;
      XLog.i(LOG_TAG, 'leftTurn request, triggerNext');
      await triggerNext();
    }
  }

  Future<void> getServerSuggestion() async {
    try {
      Map<String, dynamic> httpParams = {};
      httpParams['num_cards_left_dict'] = {"landlord": 20, "landlord_down": 17, "landlord_up": 17};
      httpParams['action'] = {"position": LandlordManager.myIdentify, "need_play_card": round == 0 ? false : true};
      httpParams['user_id'] = UserManager.deviceId;
      httpParams['round'] = ++round;
      httpParams["player_position"] = LandlordManager.myIdentify;
      httpParams['player_hand_cards'] = LandlordManager.myHandCardServerFormat;
      httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
      var jsonStr = json.encode(httpParams);
      XLog.i(LOG_TAG, 'getServerSuggestion param=$jsonStr');

      String userId = UserManager.getUserId();
      String hash = UserManager.getHash(jsonStr);
      Options options = Options();
      options.headers = {'userid': userId, 'hash': hash};

      var res = await HttpUtils.post(serverUrl, data: jsonStr, options: options);
      if (res.containsKey('action') && res['action'] != null && res['action'].isNotEmpty) {
        List<int> serverSuggestion = res['action'].cast<int>().toList();
        LandlordManager.updateServerSuggestion(serverSuggestion);
      } else {
        if (round > 1) {
          FlutterOverlayWindow.shareData([OverlayUpdateType.suggestion.index, '不出']);
        }
      }
      XLog.i(LOG_TAG, 'getServerSuggestion res=$res');
    } catch (e) {
      FlutterOverlayWindow.shareData([OverlayUpdateType.suggestion.index, '后台错误']);
      XLog.e(LOG_TAG, 'getServerSuggestion error ${e.toString()}');
    }
  }

  Future<void> tellServerIDone() async {
    List<int>? myOutCards = LandlordManager.getServerCardFormat(statusManager.myOutCardBuff);
    Map<String, dynamic> httpParams = {};
    httpParams['num_cards_left_dict'] = {"landlord": 20, "landlord_down": 17, "landlord_up": 17};
    httpParams['action'] = {"position": LandlordManager.myIdentify, "play_card": myOutCards, "need_play_card": false};
    httpParams['user_id'] = UserManager.deviceId;
    httpParams['round'] = ++round;
    httpParams["player_position"] = LandlordManager.myIdentify;
    httpParams['player_hand_cards'] = LandlordManager.myHandCardServerFormat;
    httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
    var jsonStr = json.encode(httpParams);
    XLog.i(LOG_TAG, 'tellServerIDone param=$jsonStr');

    String userId = UserManager.getUserId();
    String hash = UserManager.getHash(jsonStr);
    Options options = Options();
    options.headers = {'userid': userId, 'hash': hash};

    var res = await HttpUtils.post(serverUrl, data: jsonStr, options: options);
    XLog.i(LOG_TAG, 'tellServerIDone res=$res');
  }

  Future<void> tellServerISkip() async {
    Map<String, dynamic> httpParams = {};
    httpParams['num_cards_left_dict'] = {"landlord": 20, "landlord_down": 17, "landlord_up": 17};
    httpParams['action'] = {"position": LandlordManager.myIdentify, "play_card": [], "need_play_card": false};
    httpParams['user_id'] = UserManager.deviceId;
    httpParams['round'] = ++round;
    httpParams["player_position"] = LandlordManager.myIdentify;
    httpParams['player_hand_cards'] = LandlordManager.myHandCardServerFormat;
    httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
    var jsonStr = json.encode(httpParams);
    XLog.i(LOG_TAG, 'tellServerISkip param=$jsonStr');

    String userId = UserManager.getUserId();
    String hash = UserManager.getHash(jsonStr);
    Options options = Options();
    options.headers = {'userid': userId, 'hash': hash};

    var res = await HttpUtils.post(serverUrl, data: jsonStr, options: options);
    XLog.i(LOG_TAG, 'tellServerISkip res=$res');
  }

  Future<void> tellServerRightPlayerDone() async {
    List<int>? rightPlayerOutCards = LandlordManager.getServerCardFormat(statusManager.rightOutCardBuff);
    Map<String, dynamic> httpParams = {};
    httpParams['num_cards_left_dict'] = {"landlord": 20, "landlord_down": 17, "landlord_up": 17};
    httpParams['action'] = {"position": LandlordManager.rightPlayerIdentify, "play_card": rightPlayerOutCards, "need_play_card": false};
    httpParams['user_id'] = UserManager.deviceId;
    httpParams['round'] = ++round;
    httpParams['player_hand_cards'] = LandlordManager.myHandCardServerFormat;
    httpParams["player_position"] = LandlordManager.myIdentify;
    httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
    var jsonStr = json.encode(httpParams);
    XLog.i(LOG_TAG, 'tellServerRightPlayerDone param=$jsonStr');

    String userId = UserManager.getUserId();
    String hash = UserManager.getHash(jsonStr);
    Options options = Options();
    options.headers = {'userid': userId, 'hash': hash};

    var res = await HttpUtils.post(serverUrl, data: jsonStr, options: options);
    XLog.i(LOG_TAG, 'tellServerRightPlayerDone res=$res');
  }

  Future<void> tellServerRightPlayerSkip() async {
    Map<String, dynamic> httpParams = {};
    httpParams['num_cards_left_dict'] = {"landlord": 20, "landlord_down": 17, "landlord_up": 17};
    httpParams['action'] = {"position": LandlordManager.rightPlayerIdentify, "play_card": [], "need_play_card": false};
    httpParams['user_id'] = UserManager.deviceId;
    httpParams['round'] = ++round;
    httpParams['player_hand_cards'] = LandlordManager.myHandCardServerFormat;
    httpParams["player_position"] = LandlordManager.myIdentify;
    httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
    var jsonStr = json.encode(httpParams);
    XLog.i(LOG_TAG, 'tellServerRightPlayerSkip param=$jsonStr');

    String userId = UserManager.getUserId();
    String hash = UserManager.getHash(jsonStr);
    Options options = Options();
    options.headers = {'userid': userId, 'hash': hash};

    var res = await HttpUtils.post(serverUrl, data: jsonStr);
    XLog.i(LOG_TAG, 'tellServerRightPlayerSkip res=$res');
  }

  Future<void> tellServerLeftPlayerDone() async {
    List<int>? leftPlayerOutCards = LandlordManager.getServerCardFormat(statusManager.leftOutCardBuff);
    Map<String, dynamic> httpParams = {};
    httpParams['num_cards_left_dict'] = {"landlord": 20, "landlord_down": 17, "landlord_up": 17};
    httpParams['action'] = {"position": LandlordManager.leftPlayerIdentify, "play_card": leftPlayerOutCards, "need_play_card": false};
    httpParams['user_id'] = UserManager.deviceId;
    httpParams['round'] = ++round;
    httpParams["player_position"] = LandlordManager.myIdentify;
    httpParams['player_hand_cards'] = LandlordManager.myHandCardServerFormat;
    httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
    var jsonStr = json.encode(httpParams);
    XLog.i(LOG_TAG, 'tellServerLeftPlayerDone param=$jsonStr');

    String userId = UserManager.getUserId();
    String hash = UserManager.getHash(jsonStr);
    Options options = Options();
    options.headers = {'userid': userId, 'hash': hash};

    var res = await HttpUtils.post(serverUrl, data: jsonStr, options: options);
    XLog.i(LOG_TAG, 'tellServerLeftPlayerDone res=$res');
  }

  Future<void> tellServerLeftPlayerSkip() async {
    Map<String, dynamic> httpParams = {};
    httpParams['num_cards_left_dict'] = {"landlord": 20, "landlord_down": 17, "landlord_up": 17};
    httpParams['action'] = {"position": LandlordManager.leftPlayerIdentify, "play_card": [], "need_play_card": false};
    httpParams['user_id'] = UserManager.deviceId;
    httpParams['round'] = ++round;
    httpParams["player_position"] = LandlordManager.myIdentify;
    httpParams['player_hand_cards'] = LandlordManager.myHandCardServerFormat;
    httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
    var jsonStr = json.encode(httpParams);
    XLog.i(LOG_TAG, 'tellServerLeftPlayerSkip param=$jsonStr');

    String userId = UserManager.getUserId();
    String hash = UserManager.getHash(jsonStr);
    Options options = Options();
    options.headers = {'userid': userId, 'hash': hash};

    var res = await HttpUtils.post(serverUrl, data: jsonStr, options: options);
    XLog.i(LOG_TAG, 'tellServerLeftPlayerSkip $res');
  }
}
