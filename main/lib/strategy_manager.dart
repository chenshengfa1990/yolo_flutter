import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:ncnn_plugin/export.dart';
import 'package:screenshot_plugin/export.dart';
import 'package:yolo_flutter/strategy_queue.dart';
import 'package:yolo_flutter/user_manager.dart';

import 'status/game_status_factory.dart';
import 'status/sub/game_status_huanle.dart';
import 'http/httpUtils.dart';
import 'landlord/landlord_manager.dart';
import 'landlord_recorder.dart';
import 'overlay_window_widget.dart';
import 'status/game_status_manager.dart';

///目前欢乐和途游使用的方式
enum RequestTurn {
  myTurn,
  leftTurn,
  rightTurn,
}

///目前微乐使用的方式
enum RequestType {
  init,
  iDone,
  iSkip,
  leftDone,
  leftSkip,
  suggestion,
  rightDone,
  rightSkip,
}

class RequestEvent {
  late RequestType type;
  List<NcnnDetectModel>? data;

  RequestEvent(this.type, {this.data});

  @override
  String toString() {
    return '{type: $type, data: ${LandlordManager.getCardsSorted(data)}}';
  }
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
  // static String serverUrl = 'http://ali-ks-gos.xxrz.top/data'; //公网
  // static String userInfoUrl = 'http://ali-ks-gos.xxrz.top/self'; //用户信息
  // static String serverUrl = 'http://a-d-api.xxrz.top/data'; //公网
  // static String userInfoUrl = 'http://a-d-api.xxrz.top/self'; //用户信息
  static int round = 0;
  static RequestTurn? currentTurn;
  late GameStatusManager statusManager;

  static final StrategyManager _singleton = StrategyManager._internal();

  factory StrategyManager() {
    StrategyManager._internal();
    return _singleton;
  }

  StrategyManager._internal() {
    statusManager = GameStatusFactory.getStatusManager();
  }

  void destroy() {
    round = 0;
    currentTurn = null;
  }

  Future<void> triggerNext() async {
    XLog.i(LOG_TAG, 'currentRequestTurn: $currentTurn');
    if (currentTurn == RequestTurn.myTurn) {
      if (statusManager.myBuChu == true) {
        statusManager.myBuChu = false;
        await tellServerISkip();
      } else {
        if (statusManager.myOutCardBuffLength != statusManager.getOutCardBuffLength(BuffWho.my)) {
          XLog.i(LOG_TAG,
              'myOutCardBuffLength: ${statusManager.myOutCardBuffLength}, not equal ${statusManager.getOutCardBuffLength(BuffWho.my)}, return back');
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
        if (statusManager.rightOutCardBuffLength != statusManager.getOutCardBuffLength(BuffWho.right)) {
          XLog.i(LOG_TAG,
              'rightOutCardBuffLength: ${statusManager.rightOutCardBuffLength}, not equal ${statusManager.getOutCardBuffLength(BuffWho.right)}, return back');
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
        if (statusManager.leftOutCardBuffLength != statusManager.getOutCardBuffLength(BuffWho.left)) {
          XLog.i(LOG_TAG,
              'leftOutCardBuffLength: ${statusManager.leftOutCardBuffLength}, not equal ${statusManager.getOutCardBuffLength(BuffWho.left)}, return back');
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

  ///根据当前牌面补齐一些丢失的状态，牌面有时候会不显示不出的
  void calculateNextAction(GameStatus status, List<NcnnDetectModel>? outCard) {
    XLog.i(LOG_TAG, 'calculateNextAction status:$status, outCard: ${LandlordManager.getCardsSorted(outCard)}');
    XLog.i(LOG_TAG,
        'isFirstRound:${StrategyQueue().isFirstRound}, hasMyEvent: ${StrategyQueue().hasMyEvent}, hasRightEvent: ${StrategyQueue().hasRightEvent}, hasLeftEvent: ${StrategyQueue().hasLeftEvent}');

    ///任何一个人的出牌次数大于1，表示第一圈已经完成
    if (statusManager.myHistoryOutCardCount > 1 || statusManager.leftHistoryOutCardCount > 1 || statusManager.rightHistoryOutCardCount > 1) {
      if (StrategyQueue().isFirstRound) {
        XLog.i(LOG_TAG, 'firstRound complete, set init flag as false');
        StrategyQueue().isFirstRound = false;
      }
    }
    if (status == GameStatus.iDone) {
      if (!StrategyQueue().hasRightEvent && !StrategyQueue().isFirstRound) {
        StrategyQueue().enqueue(RequestEvent(RequestType.rightSkip));
        StrategyQueue().hasLeftEvent = false;
        if (statusManager.curGameStatus == GameStatus.rightTurn) {
          XLog.i(LOG_TAG, 'set curGameStatus from GameStatus.rightTurn to GameStatus.rightSkip');
          statusManager.curGameStatus = GameStatus.rightSkip;
          statusManager.notSetStatus = true;
        }
      }
      if (!StrategyQueue().hasLeftEvent && !StrategyQueue().isFirstRound) {
        StrategyQueue().enqueue(RequestEvent(RequestType.leftSkip));
        if (statusManager.curGameStatus == GameStatus.rightSkip || statusManager.curGameStatus == GameStatus.leftTurn) {
          XLog.i(LOG_TAG, 'set curGameStatus to GameStatus.leftSkip');
          statusManager.curGameStatus = GameStatus.leftSkip;
          statusManager.notSetStatus = true;
        }
      }
      StrategyQueue().enqueue(RequestEvent(RequestType.iDone, data: outCard));
      StrategyQueue().hasRightEvent = false;
    } else if (status == GameStatus.iSkip) {
      StrategyQueue().enqueue(RequestEvent(RequestType.iSkip));
      GameStatusManager.notifyOverlayWindow(OverlayUpdateType.suggestion, showString: '');
      StrategyQueue().hasRightEvent = false;
    } else if (status == GameStatus.rightDone) {
      if (!StrategyQueue().hasLeftEvent && !StrategyQueue().isFirstRound) {
        StrategyQueue().enqueue(RequestEvent(RequestType.leftSkip));
        StrategyQueue().hasMyEvent = false;
        if (statusManager.curGameStatus == GameStatus.leftTurn) {
          statusManager.curGameStatus = GameStatus.leftSkip;
          statusManager.notSetStatus = true;
          XLog.i(LOG_TAG, 'set curGameStatus from GameStatus.leftTurn to GameStatus.leftSkip');
        }
      }
      if (!StrategyQueue().hasMyEvent && !StrategyQueue().isFirstRound) {
        StrategyQueue().enqueue(RequestEvent(RequestType.iSkip));
        GameStatusManager.notifyOverlayWindow(OverlayUpdateType.suggestion, showString: '');
        if (statusManager.curGameStatus == GameStatus.leftSkip || statusManager.curGameStatus == GameStatus.myTurn) {
          statusManager.curGameStatus = GameStatus.iSkip;
          statusManager.notSetStatus = true;
          XLog.i(LOG_TAG, 'set curGameStatus to GameStatus.iSkip');
        }
      }
      StrategyQueue().enqueue(RequestEvent(RequestType.rightDone, data: outCard));
      StrategyQueue().hasLeftEvent = false;
    } else if (status == GameStatus.rightSkip) {
      StrategyQueue().enqueue(RequestEvent(RequestType.rightSkip));
      StrategyQueue().hasLeftEvent = false;
    } else if (status == GameStatus.leftDone) {
      if (!StrategyQueue().hasMyEvent && !StrategyQueue().isFirstRound) {
        StrategyQueue().enqueue(RequestEvent(RequestType.iSkip));
        GameStatusManager.notifyOverlayWindow(OverlayUpdateType.suggestion, showString: '');
        StrategyQueue().hasRightEvent = false;
        if (statusManager.curGameStatus == GameStatus.myTurn) {
          statusManager.curGameStatus = GameStatus.iSkip;
          statusManager.notSetStatus = true;
          XLog.i(LOG_TAG, 'set curGameStatus from GameStatus.myTurn to GameStatus.iSkip');
        }
      }
      if (!StrategyQueue().hasRightEvent && !StrategyQueue().isFirstRound) {
        StrategyQueue().enqueue(RequestEvent(RequestType.rightSkip));
        if (statusManager.curGameStatus == GameStatus.iSkip || statusManager.curGameStatus == GameStatus.rightTurn) {
          statusManager.curGameStatus = GameStatus.rightSkip;
          statusManager.notSetStatus = true;
          XLog.i(LOG_TAG, 'set curGameStatus to GameStatus.rightSkip');
        }
      }
      StrategyQueue().enqueue(RequestEvent(RequestType.leftDone, data: outCard));
      StrategyQueue().enqueue(RequestEvent(RequestType.suggestion));
      StrategyQueue().hasMyEvent = false;
    } else if (status == GameStatus.leftSkip) {
      StrategyQueue().enqueue(RequestEvent(RequestType.leftSkip));
      StrategyQueue().enqueue(RequestEvent(RequestType.suggestion));
      StrategyQueue().hasMyEvent = false;
    }
  }

  Future<void> tellServerInitialInfo() async {
    try {
      Map<String, dynamic> httpParams = {};
      httpParams['num_cards_left_dict'] = {"landlord": 20, "landlord_down": 17, "landlord_up": 17};
      httpParams['action'] = {};
      httpParams['user_id'] = UserManager.deviceId;
      httpParams['round'] = ++round;
      httpParams["player_position"] = LandlordManager.myIdentify;
      httpParams['player_hand_cards'] = LandlordManager.myHandCardServerFormat;
      httpParams['three_landlord_cards'] = LandlordManager.threeCardInt;
      var jsonStr = json.encode(httpParams);

      String userId = UserManager.getUserId();
      String hash = UserManager.getHash(jsonStr);
      Options options = Options();
      options.headers = {'userid': userId, 'hash': hash};

      XLog.i(LOG_TAG, 'tellServerInitInfo param=$jsonStr');
      var res = await HttpUtils.post(serverUrl, data: jsonStr, options: options);
      XLog.i(LOG_TAG, 'tellServerInitInfo res=$res');
    } catch (e) {
      XLog.e(LOG_TAG, 'tellServerInitInfo error ${e.toString()}');
    }
  }

  Future<void> getServerSuggestion() async {
    try {
      Map<String, dynamic> httpParams = {};
      httpParams['num_cards_left_dict'] = {"landlord": 20, "landlord_down": 17, "landlord_up": 17};
      httpParams['action'] = {"position": LandlordManager.myIdentify, "need_play_card": true};
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

  Future<void> tellServerIDone({List<NcnnDetectModel>? outCard}) async {
    List<int>? myOutCards = LandlordManager.getServerCardFormat(outCard ?? statusManager.myOutCardBuff);
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

  Future<void> tellServerRightPlayerDone({List<NcnnDetectModel>? outCard}) async {
    List<int>? rightPlayerOutCards = LandlordManager.getServerCardFormat(outCard ?? statusManager.rightOutCardBuff);
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

    var res = await HttpUtils.post(serverUrl, data: jsonStr, options: options);
    XLog.i(LOG_TAG, 'tellServerRightPlayerSkip res=$res');
  }

  Future<void> tellServerLeftPlayerDone({List<NcnnDetectModel>? outCard}) async {
    List<int>? leftPlayerOutCards = LandlordManager.getServerCardFormat(outCard ?? statusManager.leftOutCardBuff);
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
