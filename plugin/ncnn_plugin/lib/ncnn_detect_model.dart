

import 'dart:core';

class NcnnDetectModel {
  double? w; //检测目标宽度
  double? h; //检测目标高度
  double? x; //检测目标左上角x坐标
  double? y; //检测目标左上角y坐标
  String? label; //纸牌的标签1 2 3 4 5 6...
  double? prob; //检测结果可信度

  NcnnDetectModel({this.w, this.h, this.x, this.y, this.label, this.prob});

  NcnnDetectModel.fromJson(Map<String, dynamic> json)
      : w = json['w'].toDouble(),
        h = json['h'].toDouble(),
        x = json['x'].toDouble(),
        y = json['y'].toDouble(),
        label = json['label'],
        prob = json['prob'].toDouble();
}