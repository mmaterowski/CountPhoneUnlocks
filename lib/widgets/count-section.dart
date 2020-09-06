import 'package:flutter/material.dart';

class CountSection extends StatelessWidget {
  final int recordCount;
  @override
  CountSection({Key key, this.recordCount}) : super(key: key);
  Widget build(BuildContext context) {
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
