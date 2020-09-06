import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rHabbit/models/player.dart';
import '../models/phone-unlocks.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../extensions/iterableExtension.dart';

class UnlocksChart extends StatelessWidget {
  final List<Player> unlockData;
  UnlocksChart({Key key, this.unlockData}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var groupedUnlocks = unlockData.groupBy((p) => p.timestamp);
    var data = [
      PhoneUnlocks('Last week', unlockData.length + 10, Colors.blue),
      PhoneUnlocks('Yesterday', unlockData.length + 50, Colors.red),
      PhoneUnlocks('Today', unlockData.length, Colors.green),
    ];

    var series = [
      charts.Series(
        domainFn: (PhoneUnlocks clickData, _) => clickData.day,
        measureFn: (PhoneUnlocks clickData, _) => clickData.clicks,
        colorFn: (PhoneUnlocks clickData, _) => clickData.color,
        id: 'Clicks',
        data: data,
      ),
    ];

    var chart = charts.BarChart(
      series,
      animate: true,
      animationDuration: new Duration(milliseconds: 500),
    );

    var chartWidget = Padding(
      padding: EdgeInsets.all(32.0),
      child: SizedBox(
        height: 200.0,
        child: chart,
      ),
    );

    return chartWidget;
  }
}
