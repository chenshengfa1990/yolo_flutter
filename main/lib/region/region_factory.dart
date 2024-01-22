import 'dart:ui';

import 'package:yolo_flutter/region/region_type.dart';
import 'package:yolo_flutter/region/sub/jj_region.dart';
import 'package:yolo_flutter/region/sub/tuyou_region.dart';
import 'package:yolo_flutter/region/sub/weile_region.dart';

import '../landlord/landlord_manager.dart';
import '../landlord/landlord_type.dart';
import 'sub/huanle_region.dart';

class RegionFactory {
  static Rect getThreeCardRegion() {
    switch (LandlordManager.curLandlordType) {
      case LandlordType.huanle:
        return HuanleRegion.getThreeCardRegion();
    }
    return Rect.zero;
  }

  static Rect getMyHandCardRegion() {
    switch (LandlordManager.curLandlordType) {
      case LandlordType.huanle:
        return HuanleRegion.getMyHandCardRegion();
      case LandlordType.weile:
        return WeileRegion.getMyHandCardRegion();
      case LandlordType.tuyou:
        return TuyouRegion.getMyHandCardRegion();
    }
    return Rect.zero;
  }

  static Rect getMyOutCardRegion() {
    switch (LandlordManager.curLandlordType) {
      case LandlordType.huanle:
        return HuanleRegion.getMyOutCardRegion();
      case LandlordType.weile:
        return WeileRegion.getMyOutCardRegion();
      case LandlordType.tuyou:
        return TuyouRegion.getMyOutCardRegion();
    }
    return Rect.zero;
  }

  static Rect getRightPlayerOutCardRegion() {
    switch (LandlordManager.curLandlordType) {
      case LandlordType.huanle:
        return HuanleRegion.getRightPlayerOutCardRegion();
      case LandlordType.weile:
        return WeileRegion.getRightPlayerOutCardRegion();
      case LandlordType.tuyou:
        return TuyouRegion.getRightPlayerOutCardRegion();
    }
    return Rect.zero;
  }

  static Rect getLeftPlayerOutCardRegion() {
    switch (LandlordManager.curLandlordType) {
      case LandlordType.huanle:
        return HuanleRegion.getLeftPlayerOutCardRegion();
      case LandlordType.weile:
        return WeileRegion.getLeftPlayerOutCardRegion();
      case LandlordType.tuyou:
        return TuyouRegion.getLeftPlayerOutCardRegion();
    }
    return Rect.zero;
  }

  static Rect getRightPlayerBuchuRegion() {
    switch (LandlordManager.curLandlordType) {
      case LandlordType.huanle:
        return HuanleRegion.getRightPlayerBuchuRegion();
    }
    return Rect.zero;
  }

  static Rect getLeftPlayerBuchuRegion() {
    switch (LandlordManager.curLandlordType) {
      case LandlordType.huanle:
        return HuanleRegion.getLeftPlayerBuchuRegion();
    }
    return Rect.zero;
  }

  static Rect getMyBuchuRegion() {
    switch (LandlordManager.curLandlordType) {
      case LandlordType.huanle:
        return HuanleRegion.getMyBuchuRegion();
    }
    return Rect.zero;
  }

  static Rect getMyLandlordRegion() {
    switch (LandlordManager.curLandlordType) {
      case LandlordType.huanle:
        return HuanleRegion.getMyLandlordRegion();
      case LandlordType.weile:
        return WeileRegion.getMyLandlordRegion();
      case LandlordType.tuyou:
        return TuyouRegion.getMyLandlordRegion();
    }
    return Rect.zero;
  }

  static Rect getLeftLandlordRegion() {
    switch (LandlordManager.curLandlordType) {
      case LandlordType.huanle:
        return HuanleRegion.getLeftLandlordRegion();
      case LandlordType.weile:
        return WeileRegion.getLeftLandlordRegion();
      case LandlordType.tuyou:
        return TuyouRegion.getLeftLandlordRegion();
    }
    return Rect.zero;
  }

  static Rect getRightLandlordRegion() {
    switch (LandlordManager.curLandlordType) {
      case LandlordType.huanle:
        return HuanleRegion.getRightLandlordRegion();
      case LandlordType.weile:
        return WeileRegion.getRightLandlordRegion();
      case LandlordType.tuyou:
        return TuyouRegion.getRightLandlordRegion();
    }
    return Rect.zero;
  }

  static Rect getRegion(LandlordType landlordType, RegionType regionType) {
    switch (landlordType) {
      case LandlordType.weile:
        return WeileRegion.getRegion(regionType);
      case LandlordType.jj:
        return JJRegion.getRegion(regionType);
    }
    return Rect.zero;
  }
}
