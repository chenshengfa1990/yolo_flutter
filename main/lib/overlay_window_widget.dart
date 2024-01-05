import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import 'landlord_recorder.dart';

class OverlayWindowWidget extends StatefulWidget {
  const OverlayWindowWidget({Key? key}) : super(key: key);

  @override
  State<OverlayWindowWidget> createState() => _OverlayWindowState();
}

class _OverlayWindowState extends State<OverlayWindowWidget> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              border: Border.all(color: Colors.white, width: 2)),
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
  }
}

class DraggableContent extends StatefulWidget {
  const DraggableContent({Key? key}) : super(key: key);

  @override
  State<DraggableContent> createState() => _DraggableContentState();
}

class _DraggableContentState extends State<DraggableContent> {
  Offset position = const Offset(0.0, 0.0);
  ValueNotifier<String> gameStatusNotifier = ValueNotifier('准备中');
  ValueNotifier<String> threeCardNotifier = ValueNotifier('');
  ValueNotifier<String> handCardsNotifier = ValueNotifier('');
  ValueNotifier<String> myOutCardsNotifier = ValueNotifier('');
  ValueNotifier<String> leftPlayerCardNotifier = ValueNotifier('');
  ValueNotifier<String> rightPlayerCardNotifier = ValueNotifier('');
  ValueNotifier<String> suggestionOutCardNotifier = ValueNotifier('');
  ValueNotifier<String> cardDWNumNotifier = ValueNotifier('');
  ValueNotifier<String> cardXWNumNotifier = ValueNotifier('');
  ValueNotifier<String> card2NumNotifier = ValueNotifier('');
  ValueNotifier<String> cardANumNotifier = ValueNotifier('');
  ValueNotifier<String> cardKNumNotifier = ValueNotifier('');
  ValueNotifier<String> cardQNumNotifier = ValueNotifier('');
  ValueNotifier<String> cardJNumNotifier = ValueNotifier('');
  ValueNotifier<String> card10NumNotifier = ValueNotifier('');
  ValueNotifier<String> card9NumNotifier = ValueNotifier('');
  ValueNotifier<String> card8NumNotifier = ValueNotifier('');
  ValueNotifier<String> card7NumNotifier = ValueNotifier('');
  ValueNotifier<String> card6NumNotifier = ValueNotifier('');
  ValueNotifier<String> card5NumNotifier = ValueNotifier('');
  ValueNotifier<String> card4NumNotifier = ValueNotifier('');
  ValueNotifier<String> card3NumNotifier = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event != null) {
        List<dynamic> showData = event as List<dynamic>;
        int showType = showData[0];
        if (showType == OverlayUpdateType.gameStatus.index) {
          gameStatusNotifier.value = showData[1];
        } else if (showType == OverlayUpdateType.threeCard.index) {
          threeCardNotifier.value = showData[1];
        } else if (showType == OverlayUpdateType.handCard.index) {
          handCardsNotifier.value = showData[1];
        } else if (showType == OverlayUpdateType.myOutCard.index) {
          myOutCardsNotifier.value = showData[1];
        } else if (showType == OverlayUpdateType.leftOutCard.index) {
          leftPlayerCardNotifier.value = showData[1];
        } else if (showType == OverlayUpdateType.rightOutCard.index) {
          rightPlayerCardNotifier.value = showData[1];
        } else if (showType == OverlayUpdateType.suggestion.index) {
          suggestionOutCardNotifier.value = showData[1];
        } else if (showType == OverlayUpdateType.cardRecorder.index) {
          var leftCardMap = showData[1];
          cardDWNumNotifier.value = leftCardMap['dw'].toString();
          cardXWNumNotifier.value = leftCardMap['xw'].toString();
          card2NumNotifier.value = leftCardMap['2'].toString();
          cardANumNotifier.value = leftCardMap['A'].toString();
          cardKNumNotifier.value = leftCardMap['K'].toString();
          cardQNumNotifier.value = leftCardMap['Q'].toString();
          cardJNumNotifier.value = leftCardMap['J'].toString();
          card10NumNotifier.value = leftCardMap['10'].toString();
          card9NumNotifier.value = leftCardMap['9'].toString();
          card8NumNotifier.value = leftCardMap['8'].toString();
          card7NumNotifier.value = leftCardMap['7'].toString();
          card6NumNotifier.value = leftCardMap['6'].toString();
          card5NumNotifier.value = leftCardMap['5'].toString();
          card4NumNotifier.value = leftCardMap['4'].toString();
          card3NumNotifier.value = leftCardMap['3'].toString();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Column(
        children: [
          Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: const Center(
                      child: Text(
                        'W',
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: cardDWNumNotifier,
                      builder: (BuildContext context, value, Widget? child) {
                        return Center(child: Text(value, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))));
                      },
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                        border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white))),
                    child: const Center(
                      child: Text(
                        'w',
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: cardXWNumNotifier,
                      builder: (BuildContext context, value, Widget? child) {
                        return Center(child: Text(value, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))));
                      },
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: const Center(
                      child: Text(
                        '2',
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: card2NumNotifier,
                      builder: (BuildContext context, value, Widget? child) {
                        return Center(child: Text(value, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))));
                      },
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: const Center(
                      child: Text(
                        'A',
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: cardANumNotifier,
                      builder: (BuildContext context, value, Widget? child) {
                        return Center(child: Text(value, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))));
                      },
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: const Center(
                      child: Text(
                        'K',
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: cardKNumNotifier,
                      builder: (BuildContext context, value, Widget? child) {
                        return Center(child: Text(value, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))));
                      },
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: const Center(
                      child: Text(
                        'Q',
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: cardQNumNotifier,
                      builder: (BuildContext context, value, Widget? child) {
                        return Center(child: Text(value, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))));
                      },
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: const Center(
                      child: Text(
                        'J',
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: cardJNumNotifier,
                      builder: (BuildContext context, value, Widget? child) {
                        return Center(child: Text(value, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))));
                      },
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: const Center(
                      child: Text(
                        '10',
                        style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: card10NumNotifier,
                      builder: (BuildContext context, value, Widget? child) {
                        return Center(child: Text(value, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))));
                      },
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: const Center(
                      child: Text(
                        '9',
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: card9NumNotifier,
                      builder: (BuildContext context, value, Widget? child) {
                        return Center(child: Text(value, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))));
                      },
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: const Center(
                      child: Text(
                        '8',
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: card8NumNotifier,
                      builder: (BuildContext context, value, Widget? child) {
                        return Center(child: Text(value, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))));
                      },
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: const Center(
                      child: Text(
                        '7',
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: card7NumNotifier,
                      builder: (BuildContext context, value, Widget? child) {
                        return Center(child: Text(value, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))));
                      },
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: const Center(
                      child: Text(
                        '6',
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: card6NumNotifier,
                      builder: (BuildContext context, value, Widget? child) {
                        return Center(child: Text(value, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))));
                      },
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: const Center(
                      child: Text(
                        '5',
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: card5NumNotifier,
                      builder: (BuildContext context, value, Widget? child) {
                        return Center(child: Text(value, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))));
                      },
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: const Center(
                      child: Text(
                        '4',
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: card4NumNotifier,
                      builder: (BuildContext context, value, Widget? child) {
                        return Center(child: Text(value, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))));
                      },
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: const Center(
                      child: Text(
                        '3',
                        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    width: 15,
                    height: 18,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(width: 1, color: Colors.white), bottom: BorderSide(width: 1, color: Colors.white)),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: card3NumNotifier,
                      builder: (BuildContext context, value, Widget? child) {
                        return Center(child: Text(value, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))));
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
          Expanded(
            child: Container(
                width: 225,
                decoration: const BoxDecoration(border: Border(right: BorderSide(width: 1, color: Colors.white))),
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            const Text('手牌:', style: TextStyle(fontSize: 10, color: Colors.white)),
                            ValueListenableBuilder(
                                valueListenable: handCardsNotifier,
                                builder: (BuildContext context, value, Widget? child) {
                                  return Text(value, style: const TextStyle(fontSize: 6, color: Colors.white));
                                }),
                          ],
                        )),
                    Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            const Text('建议出牌:', style: TextStyle(fontSize: 10, color: Colors.white)),
                            ValueListenableBuilder(
                              valueListenable: suggestionOutCardNotifier,
                              builder: (BuildContext context, value, Widget? child) {
                                return Text(value, style: const TextStyle(fontSize: 8, color: Colors.white));
                              },
                            ),
                          ],
                        )),
                  ],
                )),
          )
        ],
      ),
      Expanded(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('状态:', style: TextStyle(fontSize: 9, color: Colors.white)),
              ValueListenableBuilder(
                valueListenable: gameStatusNotifier,
                builder: (BuildContext context, value, Widget? child) {
                  return Text(value, style: const TextStyle(fontSize: 8, color: Colors.white));
                },
              ),
            ],
          ),
          Row(
            children: [
              const Text('3张牌:', style: TextStyle(fontSize: 9, color: Colors.white)),
              ValueListenableBuilder(
                valueListenable: threeCardNotifier,
                builder: (BuildContext context, value, Widget? child) {
                  return Text(value, style: const TextStyle(fontSize: 8, color: Colors.white));
                },
              ),
            ],
          ),
          Row(
            children: [
              const Text('上家:', style: TextStyle(fontSize: 9, color: Colors.white)),
              ValueListenableBuilder(
                valueListenable: leftPlayerCardNotifier,
                builder: (BuildContext context, value, Widget? child) {
                  return Text(value, style: const TextStyle(fontSize: 6, color: Colors.white));
                },
              ),
            ],
          ),
          Row(
            children: [
              const Text('下家:', style: TextStyle(fontSize: 9, color: Colors.white)),
              ValueListenableBuilder(
                valueListenable: rightPlayerCardNotifier,
                builder: (BuildContext context, value, Widget? child) {
                  return Text(value, style: const TextStyle(fontSize: 6, color: Colors.white));
                },
              ),
            ],
          ),
          Row(
            children: [
              const Text('我出牌:', style: TextStyle(fontSize: 7, color: Colors.white)),
              ValueListenableBuilder(
                valueListenable: myOutCardsNotifier,
                builder: (BuildContext context, value, Widget? child) {
                  return Text(value, style: const TextStyle(fontSize: 6, color: Colors.white));
                },
              ),
            ],
          ),
        ],
      )),
    ]);
  }
}

enum OverlayUpdateType {
  gameStatus,
  threeCard,
  handCard,
  myOutCard,
  leftOutCard,
  rightOutCard,
  suggestion,
  cardRecorder, //记牌器
}
