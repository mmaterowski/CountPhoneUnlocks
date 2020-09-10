import 'package:charts_flutter/flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rHabbit/models/player.dart';
import "package:collection/collection.dart";
import '../models/phone-unlocks.dart';
import 'package:charts_flutter/flutter.dart' as charts;

enum Type { today, week, month, year }

class UnlocksChart extends StatelessWidget {
  final List<Player> unlockData;
  final Type chartType;

  UnlocksChart({Key key, this.unlockData, this.chartType}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<PhoneUnlocks> data = new List<PhoneUnlocks>();
    charts.TimeSeriesChart chart;
    if (this.chartType == Type.today) {
      data = buildTodaySeries(unlockData);
    }
    if (this.chartType == Type.week) {
      data = buildWeekSeries(unlockData);
    }
    var series = createSeries(data);

    chart = charts.TimeSeriesChart(
      series,
      defaultRenderer: new charts.BarRendererConfig<DateTime>(),
      domainAxis: buildAxisSpec(chartType),
      animate: true,
      animationDuration: new Duration(milliseconds: 500),
      defaultInteractions: false,
      behaviors: [new charts.SelectNearest(), new charts.DomainHighlighter()],
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

AxisSpec<dynamic> buildAxisSpec(Type type) {
  if (type == Type.week) {
    return charts.DateTimeAxisSpec(
      tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
        day: charts.TimeFormatterSpec(
          format: 'dd MM',
          transitionFormat: 'dd MM',
        ),
      ),
      tickProviderSpec: charts.DayTickProviderSpec(increments: [1]),
    );
  }
  if (type == Type.today) {
    return charts.DateTimeAxisSpec(
      tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
        hour:
            new charts.TimeFormatterSpec(format: "Hm", transitionFormat: "Hm"),
      ),
    );
  }
}

List<charts.Series<PhoneUnlocks, DateTime>> createSeries(
    List<PhoneUnlocks> unlockData) {
  return [
    new charts.Series<PhoneUnlocks, DateTime>(
      id: 'PhoneUnlocks',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (PhoneUnlocks unlocks, _) => unlocks.timestamp,
      measureFn: (PhoneUnlocks unlocks, _) => unlocks.clicks,
      data: unlockData,
    )
  ];
}

String getStringFromDate(DateTime dateTime) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(dateTime);
}

List<PhoneUnlocks> buildWeekSeries(List<Player> unlockData) {
  List<PhoneUnlocks> data = new List<PhoneUnlocks>();
  var todayRecords = getThisWeekRecords(unlockData);
  for (var i = 0; i < 7; i++) {
    int counts = 0;
    if (todayRecords.length - i <= 0) {
      continue;
    }

    counts = todayRecords[todayRecords.keys.elementAt(i)].length;
    data.add(new PhoneUnlocks(
        DateTime.parse(todayRecords.keys.elementAt(i)), counts));
  }
  return data;
}

Map<String, List<Player>> getThisWeekRecords(List<Player> players) {
  var groupedRecords =
      groupBy(players, (Player obj) => weekNumber(obj.timestamp));
  var thisWeek = weekNumber(DateTime.now());
  if (groupedRecords.containsKey(thisWeek)) {
    var thisWeekRecords = groupedRecords[thisWeek];
    return groupBy(
        thisWeekRecords, (Player obj) => getStringFromDate(obj.timestamp));
  }
  return Map<String, List<Player>>();
}

List<PhoneUnlocks> buildTodaySeries(List<Player> unlockData) {
  List<PhoneUnlocks> data = new List<PhoneUnlocks>();
  var todayRecords = getTodayRecords(unlockData);
  for (var key in todayRecords.keys) {
    var date = new DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, key);
    data.add(new PhoneUnlocks(date, todayRecords[key].length));
  }
  return data;
}

Map<int, List<Player>> getTodayRecords(List<Player> players) {
  var groupedRecords =
      groupBy(players, (Player obj) => getStringFromDate(obj.timestamp));
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  var today = formatter.format(DateTime.now());
  if (groupedRecords.containsKey(today)) {
    return groupBy(groupedRecords[today], (Player obj) => obj.timestamp.hour);
  }
  return Map<int, List<Player>>();
}

int weekNumber(DateTime date) {
  int dayOfYear = int.parse(DateFormat("D").format(date));
  return ((dayOfYear - date.weekday + 10) / 7).floor();
}
