import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rHabbit/models/player.dart';
import "package:collection/collection.dart";
import '../models/phone-unlocks.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../extensions/iterableExtension.dart';

class UnlocksChart extends StatelessWidget {
  final List<Player> unlockData;
  UnlocksChart({Key key, this.unlockData}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<PhoneUnlocks> data = new List<PhoneUnlocks>();
    var groupedUnlocks =
        unlockData.groupBy((p) => getStringFromDate(p.timestamp));
    var groupedRecords =
        groupBy(unlockData, (Player obj) => getStringFromDate(obj.timestamp));
    var today =
        "${DateTime.now().year.toString()}/${DateTime.now().month.toString()}/${DateTime.now().day.toString()}";
    if (groupedUnlocks.containsKey(today)) {
      var todayData = groupedUnlocks[today];
      var groupedByHour =
          groupBy(todayData, (Player obj) => obj.timestamp.hour);

      for (var i = 0; i < 24; i++) {
        int counts = 0;
        if (groupedByHour.containsKey(i)) {
          counts = groupedByHour[i].length;
        }
        data.add(new PhoneUnlocks(i.toString(), counts, Colors.red));
      }
    }

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

getStringFromDate(DateTime dateTime) {
  return dateTime.year.toString() +
      "/" +
      dateTime.month.toString() +
      "/" +
      dateTime.day.toString();
}
