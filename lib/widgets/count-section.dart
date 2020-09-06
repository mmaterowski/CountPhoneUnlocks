import 'package:flutter/material.dart';
import 'package:rHabbit/widgets/animated-count.dart';

class CountSection extends StatelessWidget {
  final int recordCount;
  @override
  CountSection({Key key, this.recordCount}) : super(key: key);
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        'You have unlocked Your phone',
        style: Theme.of(context).textTheme.headline6,
        textAlign: TextAlign.center,
      ),
      Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(width: 2),
          shape: BoxShape.circle,
          // You can use like this way or like the below line
          //borderRadius: new BorderRadius.circular(30.0),
          color: Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedCount(
                count: recordCount, duration: Duration(milliseconds: 500))
          ],
        ),
      ),
      Text(
        'times today',
        style: Theme.of(context).textTheme.headline6,
        textAlign: TextAlign.center,
      ),
    ]);
  }
}
