import 'dart:ui';

import 'package:yolo_flutter/region/region_type.dart';
import 'package:yolo_flutter/region/sub/jj_region.dart';
import 'package:yolo_flutter/region/sub/weile_region.dart';

import '../landlord/landlord_type.dart';

class RegionFactory {
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
