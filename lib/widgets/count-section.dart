import 'package:flutter/material.dart';

class CountSection {
  static Column build(BuildContext context, int recordCount) {
    return Column(children: [
      Text(
        'You have unlocked the phone this many times today:',
        style: Theme.of(context).textTheme.headline6,
        textAlign: TextAlign.center,
      ),
      Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('$recordCount',
              style: Theme.of(context).textTheme.headline4)),
    ]);
  }
}
