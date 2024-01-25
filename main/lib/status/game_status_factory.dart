import 'package:yolo_flutter/landlord/landlord_manager.dart';
import 'package:yolo_flutter/landlord/landlord_type.dart';
import 'package:yolo_flutter/status/sub/game_status_tuyou.dart';
import 'package:yolo_flutter/status/sub/game_status_weile.dart';

import 'sub/game_status_huanle.dart';
import 'game_status_manager.dart';

class GameStatusFactory {
  static GameStatusManager getStatusManager() {
    switch (LandlordManager.curLandlordType) {
      case LandlordType.huanle:
        return GameStatusHuanle();
      case LandlordType.weile:
        return GameStatusWeile();
      case LandlordType.tuyou:
        return GameStatusTuyou();
    }
    return GameStatusHuanle();
  }
}
