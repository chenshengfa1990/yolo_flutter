import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayWindowWidget extends StatefulWidget {
  const OverlayWindowWidget({Key? key}) : super(key: key);

  @override
  State<OverlayWindowWidget> createState() => _OverlayWindowState();
}

class _OverlayWindowState extends State<OverlayWindowWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.red.withOpacity(0.01),
        body: Container(
          decoration: BoxDecoration(
              color: Colors.transparent, borderRadius: const BorderRadius.all(Radius.circular(4)), border: Border.all(color: Colors.white, width: 2)),
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
  String gameStatus = '准备中';
  String threeCard = '';
  String handCards = '';
  String myOutCards = '';
  String leftPlayerCard = '';
  String rightPlayerCard = '';
  String suggestionOutCard = '';

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event != null) {
        if (event is String) {
          setState(() {
            suggestionOutCard = event;
          });
        } else {
          setState(() {
            List<dynamic> showList = event as List<dynamic>;
            gameStatus = showList[0];
            threeCard = showList[1];
            leftPlayerCard = showList[2];
            rightPlayerCard = showList[3];
            handCards = showList[4];
            myOutCards = showList[5];
          });
        }
      }
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.black.withOpacity(0.2),
              child: Row(
                children: [
                  const Text('状态:', style: TextStyle(fontSize: 12, color: Colors.white)),
                  Text(gameStatus, style: const TextStyle(fontSize: 8, color: Colors.white)),
                ],
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.2),
              child: Row(
                children: [
                  const Text('3张牌:', style: TextStyle(fontSize: 12, color: Colors.white)),
                  Text(threeCard, style: const TextStyle(fontSize: 8, color: Colors.white)),
                ],
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.2),
              child: Row(
                children: [
                  const Text('上家:', style: TextStyle(fontSize: 12, color: Colors.white)),
                  Text(leftPlayerCard, style: const TextStyle(fontSize: 8, color: Colors.white)),
                ],
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.2),
              child: Row(
                children: [
                  const Text('下家:', style: TextStyle(fontSize: 12, color: Colors.white)),
                  Text(rightPlayerCard, style: const TextStyle(fontSize: 8, color: Colors.white)),
                ],
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.2),
              child: Row(
                children: [
                  const Text('手牌:', style: TextStyle(fontSize: 12, color: Colors.white)),
                  Text(handCards, style: const TextStyle(fontSize: 8, color: Colors.white)),
                ],
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.2),
              child: Row(
                children: [
                  const Text('建议出牌:', style: TextStyle(fontSize: 12, color: Colors.white)),
                  Text(suggestionOutCard, style: const TextStyle(fontSize: 8, color: Colors.white)),
                ],
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.2),
              child: Row(
                children: [
                  const Text('我的出牌:', style: TextStyle(fontSize: 12, color: Colors.white)),
                  Text(myOutCards, style: const TextStyle(fontSize: 8, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
