import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DialogUtil {
  ///自定义对话框
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    bool barrierDismissible = true,
    required WidgetBuilder builder,
    String dialogName = "",
    Function? btnTapBgOnPress,
    Color? barrierColor,
  }) {
    final ThemeData theme = Theme.of(context);
    return showGeneralDialog(
      useRootNavigator: false,
      context: context,
      routeSettings: RouteSettings(name: dialogName),
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        final Widget pageChild = Builder(builder: builder);
        return GestureDetector(
            child: Scaffold(
                backgroundColor: Colors.transparent,
                resizeToAvoidBottomInset: true,
                body: GestureDetector(
                  child: Center(
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: Builder(builder: (BuildContext context) {
                              return theme != null ? Theme(data: theme, child: pageChild) : pageChild;
                            }),
                          ),
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    //do nothing
                  },
                )),
            onTap: () {
              FocusScope.of(buildContext).unfocus();
              if (!barrierDismissible) {
                return;
              }
              if (btnTapBgOnPress != null) {
                btnTapBgOnPress();
              }
              Navigator.of(buildContext).pop();
            });
      },
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: barrierColor ?? Colors.black54,
    );
  }
}
