import 'package:flutter/material.dart';
import 'package:rHabbit/widgets/animated-count.dart';

class StatsSection extends StatelessWidget {
  final int averageUnlockCount;
  @override
  StatsSection({Key key, this.averageUnlockCount}) : super(key: key);
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).bottomAppBarColor,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'You usually unlock Your phone $averageUnlockCount times a day',
                    style: Theme.of(context).textTheme.subtitle2,
                    textAlign: TextAlign.center,
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  FractionallySizedBox(
                      widthFactor: 0.6,
                      child: RaisedButton(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Icon(Icons.insert_chart),
                              Text("See more details")
                            ]),
                        elevation: 2.0,
                        autofocus: false,
                        clipBehavior: Clip.hardEdge,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(26 / 1.5)),
                        onPressed: () => {},
                      ))
                ])));
  }
}
