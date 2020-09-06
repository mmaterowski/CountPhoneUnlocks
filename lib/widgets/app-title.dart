import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rHabbit/styles/my_flutter_app_icons.dart' as AppIcon;

class AppTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
              child: Icon(
            AppIcon.MyFlutterApp.app_icon,
            size: 25,
          )),
          TextSpan(
              text: " rHabbit", style: Theme.of(context).textTheme.headline5),
        ],
      ),
    );
  }
}
