import 'dart:async';

///参考：https://www.jianshu.com/p/2b70ef340e82

/// 函数防抖(用于防止重复点击处理，快速大量重复处理)
///
/// 只处理最后一次点击（延时一定时间处理），之前重复的点击不做处理
///
/// [func]: 要执行的方法
///
/// [delay]: 要迟延的时长, 默认为500 ms
///
/// [showLog]: 是否显示日志
Function funcDebounce(
  Function func, {
  Duration delay = const Duration(milliseconds: 300),
  bool showLog = false,
}) {
  Timer? timer;
  target() {
    if (timer?.isActive == true) {
      timer?.cancel();
      if (showLog == true) {
        print('funcDebounce() debounce...');
      }
    }
    timer = Timer(delay, () {
      if (showLog == true) {
        print('funcDebounce() func?.call()');
      }
      func.call();
      if (showLog == true) {
        print('funcDebounce() timer complete');
      }
    });
  }

  return target;
}

///
/// 函数节流(用于防止重复点击处理，快速大量重复处理)
///
/// 执行完func，才会执行下一个func，在执行完之前的期间的func的会抛弃
///
/// [func]: 要执行的方法
///
/// [delay]: 要节流的时长, 默认为2000 ms
///
/// [showLog]: 是否显示日志
Function()? funcThrottle(
  Function func, {
  Duration delay = const Duration(milliseconds: 1000),
  bool showLog = false,
}) {
  bool enable = true;
  target() {
    if (enable != true) {
      if (showLog == true) {
        print('funcThrottle() throttle...');
      }
      return;
    }

    if (showLog == true) {
      print('funcThrottle() func?.call()');
    }
    //
    enable = false;
    Future.delayed(delay).then((value) {
      if (showLog == true) {
        print('funcThrottle() delay enable = true');
      }
      enable = true;
    });
    func.call();
  }

  return target;
}
