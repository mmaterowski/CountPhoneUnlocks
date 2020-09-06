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
      PhoneUnlocks('Last week', 26, Colors.blue),
      PhoneUnlocks('Yesterday', 12, Colors.red),
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
