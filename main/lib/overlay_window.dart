import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:yolo_flutter/screen_shot.dart';

class OverlayWindow extends StatefulWidget {
  const OverlayWindow({Key? key}) : super(key: key);

  @override
  State<OverlayWindow> createState() => _OverlayWindowState();
}

class _OverlayWindowState extends State<OverlayWindow> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.red.withOpacity(0.3),
        body: Container(
          color: Colors.transparent,
          child: Stack(
            children: const [
              DraggableContent(),
              // ScreenShotView(),
              // const Positioned(left: 0, right: 0, bottom: 20, child: Text("出牌提示", style: TextStyle(color: Colors.red, fontSize: 18),))
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Timer.periodic(const Duration(milliseconds: 1000), (timer) {
    //   setState(() {});
    // });
  }
}

class DraggableContent extends StatefulWidget {
  const DraggableContent({Key? key}) : super(key: key);

  @override
  State<DraggableContent> createState() => _DraggableContentState();
}

class _DraggableContentState extends State<DraggableContent> {
  Offset position = const Offset(0.0, 0.0);
  int notice = 0;
  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      setState(() {
        notice = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var statusBarHeight = MediaQuery.of(context).padding.top;
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Container(
        padding: const EdgeInsets.only(left: 10, top: 15),
        color: Colors.black.withOpacity(0.3),
        child: Column(children: [
          Text('上家$notice'),
          const SizedBox(height: 5),
          Text('下家'),
          const SizedBox(height: 5),
          Text('手牌$notice'),
        ],),
      ),
    );
  }
}
