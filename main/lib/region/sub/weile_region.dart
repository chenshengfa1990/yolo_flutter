import 'dart:ui';

import 'package:yolo_flutter/region/region_type.dart';

class WeileRegion {
  static Rect getRegion(RegionType regionType) {
    if (regionType == RegionType.leftSkip) {
      return getLeftSkipRegion();
    }
    return Rect.zero;
  }

  static Rect getLeftSkipRegion() {
    return const Rect.fromLTRB(170, 95, 270, 155);
  }
}
