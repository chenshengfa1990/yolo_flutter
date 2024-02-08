import 'dart:collection';

import 'package:flutter_xlog/flutter_xlog.dart';
import 'package:yolo_flutter/strategy_manager.dart';

class StrategyQueue {
  static String LOG_TAG = "StrategyQueue";
  bool isRequesting = false;
  Queue<RequestEvent> queue = Queue<RequestEvent>();
  RequestEvent? lastEvent;
  bool hasMyEvent = false; //该轮是否需要补全该角色的策略，如果已经出过牌或者不出，则不需要补全，新一轮的时候，该状态重置
  bool hasLeftEvent = false;
  bool hasRightEvent = false;

  bool isFirstRound = true; //是否是第一轮，用来判断是否补全策略，第一轮不需要补全

  static final StrategyQueue _singleton = StrategyQueue._internal();

  factory StrategyQueue() {
    return _singleton;
  }

  StrategyQueue._internal();

  void enqueue(RequestEvent event) {
    switch (event.type) {
      case RequestType.iDone:
      case RequestType.iSkip:
        hasMyEvent = true;
        break;
      case RequestType.leftDone:
      case RequestType.leftSkip:
        hasLeftEvent = true;
        break;
      case RequestType.rightDone:
      case RequestType.rightSkip:
        hasRightEvent = true;
        break;
    }
    XLog.i(LOG_TAG, 'strategy enqueue, event:$event');
    queue.add(event);
    _tryTriggerNext();
  }

  void _tryTriggerNext() {
    XLog.i(LOG_TAG, '_tryTriggerNext');
    if (isRequesting == false) {
      if (queue.isNotEmpty) {
        lastEvent = queue.removeFirst();
        _handleRequest(lastEvent!);
      } else {
        XLog.i(LOG_TAG, 'queue is null, no event trigger');
      }
    } else {
      XLog.i(LOG_TAG, '_tryTriggerNext fail, there is a request handling~');
    }
  }

  void _handleRequest(RequestEvent event) async {
    XLog.i(LOG_TAG, '_handleRequest, event: $event');
    isRequesting = true;
    switch (event.type) {
      case RequestType.init:
        await StrategyManager().tellServerInitialInfo();
        break;
      case RequestType.iDone:
        await StrategyManager().tellServerIDone(outCard: event.data);
        break;
      case RequestType.iSkip:
        await StrategyManager().tellServerISkip();
        break;
      case RequestType.leftDone:
        await StrategyManager().tellServerLeftPlayerDone(outCard: event.data);
        break;
      case RequestType.leftSkip:
        await StrategyManager().tellServerLeftPlayerSkip();
        break;
      case RequestType.rightDone:
        await StrategyManager().tellServerRightPlayerDone(outCard: event.data);
        break;
      case RequestType.rightSkip:
        await StrategyManager().tellServerRightPlayerSkip();
        break;
      case RequestType.suggestion:
        StrategyManager().getServerSuggestion();
        break;
    }
    isRequesting = false;
    XLog.i(LOG_TAG, '_handleRequest end, event: $event');
    _tryTriggerNext();
  }

  void destroy() {
    XLog.i(LOG_TAG, 'StrategyQueue destroy');
    isRequesting = false;
    queue.clear();
    lastEvent = null;
    hasMyEvent = false;
    hasLeftEvent = false;
    hasRightEvent = false;
    isFirstRound = true;
  }
}
