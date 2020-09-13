import 'package:charts_flutter/flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import "package:collection/collection.dart";
import 'package:rHabbit/models/unlock-record.dart';
import '../models/phone-unlocks.dart';
import 'package:charts_flutter/flutter.dart' as charts;

enum ChartType { today, week, month, year }

class UnlocksChart extends StatelessWidget {
  final List<UnlockRecord> unlockData;
  final ChartType chartType;

  UnlocksChart({Key key, this.unlockData, this.chartType}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<PhoneUnlocks> data = new List<PhoneUnlocks>();
    charts.TimeSeriesChart chart;
    if (this.chartType == ChartType.today) {
      data = buildTodaySeries(unlockData);
    }
    if (this.chartType == ChartType.week) {
      data = buildWeekSeries(unlockData);
    }
    if (this.chartType == ChartType.month) {
      data = buildMonthSeries(unlockData);
    }
    if (this.chartType == ChartType.year) {
      data = buildYearSeries(unlockData);
    }
    var series = createSeries(data);

    chart = charts.TimeSeriesChart(series,
        defaultRenderer: new charts.BarRendererConfig<DateTime>(),
        domainAxis: buildAxisSpec(chartType, data),
        primaryMeasureAxis: new charts.NumericAxisSpec(
            renderSpec: new charts.GridlineRendererSpec(

                // Tick and Label styling here.
                labelStyle: new charts.TextStyleSpec(
                    fontSize: 13, // size in Pts.
                    color: charts.MaterialPalette.black),

                // Change the line colors to match text color.
                lineStyle: new charts.LineStyleSpec(
                    color: charts.MaterialPalette.black))),
        animate: true,
        animationDuration: new Duration(milliseconds: 500),
        defaultInteractions: false,
        behaviors: [
          new charts.SelectNearest(),
          new charts.DomainHighlighter()
        ]);

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

AxisSpec<dynamic> buildAxisSpec(ChartType type, List<PhoneUnlocks> data) {
  if (type == ChartType.year) {
    return charts.DateTimeAxisSpec(
        renderSpec: new charts.SmallTickRendererSpec(
            minimumPaddingBetweenLabelsPx: 0,
            // Tick and Label styling here.
            labelStyle: new charts.TextStyleSpec(
                fontSize: 12, // size in Pts.
                color: charts.MaterialPalette.black),

            // Change the line colors to match text color.
            lineStyle:
                new charts.LineStyleSpec(color: charts.MaterialPalette.black)),
        tickFormatterSpec: AutoDateTimeTickFormatterSpec(
            month: TimeFormatterSpec(
          format: 'MMM',
          transitionFormat: 'MMM',
        )));
  }

  if (type == ChartType.month) {
    return charts.DateTimeAxisSpec(
      tickFormatterSpec: AutoDateTimeTickFormatterSpec(
        day: TimeFormatterSpec(
          format: 'dd.MM',
          transitionFormat: 'dd.MM',
        ),
      ),
    );
  }

  if (type == ChartType.week) {
    return charts.DateTimeAxisSpec(
      tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
        day: charts.TimeFormatterSpec(
          format: 'dd.MM',
          transitionFormat: 'dd.MM',
        ),
      ),
      tickProviderSpec: charts.DayTickProviderSpec(increments: [1]),
    );
  }
  if (type == ChartType.today) {
    var dayStart = data.first.timestamp;
    dayStart = new DateTime(dayStart.year, dayStart.month, dayStart.day, 0);
    return charts.DateTimeAxisSpec(
        tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
      hour: new charts.TimeFormatterSpec(
          format: "HH:mm", transitionFormat: "HH:mm"),
    ));
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

List<PhoneUnlocks> buildYearSeries(List<UnlockRecord> unlockData) {
  List<PhoneUnlocks> data = new List<PhoneUnlocks>();
  var thisYearRecords = getThisYearRecords(unlockData);
  for (var i = 0; i < 12; i++) {
    int counts = 0;
    if (thisYearRecords.containsKey(i)) {
      counts = thisYearRecords[i].length;
      data.add(
          new PhoneUnlocks(new DateTime(DateTime.now().year, i + 1), counts));
    }
  }
  addEmtyRecordsIfNeeded(data);

  return data;
}

void addEmtyRecordsIfNeeded(List<PhoneUnlocks> data) {
  if (data.length == 1) {
    if (data[0].timestamp.month != 12) {
      data.add(new PhoneUnlocks(
          new DateTime(data[0].timestamp.year, data[0].timestamp.month + 1),
          0));
    }
    if (data[0].timestamp.month != 0)
      data.add(new PhoneUnlocks(
          new DateTime(data[0].timestamp.year, data[0].timestamp.month - 1),
          0));
  }
}

Map<int, List<UnlockRecord>> getThisYearRecords(List<UnlockRecord> record) {
  var groupedRecords =
      groupBy(record, (UnlockRecord obj) => (obj.timestamp.year));
  var thisYear = DateTime.now().year;
  if (groupedRecords.containsKey(thisYear)) {
    var thisYearRecords = groupedRecords[thisYear];
    // thisYearRecords.add(new UnlockRecord(4121244, new DateTime(2020, 1, 13)));
    // thisYearRecords.add(new UnlockRecord(412164, new DateTime(2020, 2, 13)));
    // thisYearRecords.add(new UnlockRecord(44221244, new DateTime(2020, 3, 13)));
    // thisYearRecords.add(new UnlockRecord(44221241, new DateTime(2020, 4, 13)));
    // thisYearRecords.add(new UnlockRecord(44224444, new DateTime(2020, 5, 13)));
    // thisYearRecords.add(new UnlockRecord(44224444, new DateTime(2020, 6, 13)));
    // thisYearRecords.add(new UnlockRecord(424112444, new DateTime(2020, 7, 15)));
    // thisYearRecords.add(new UnlockRecord(44423444, new DateTime(2020, 8, 1)));
    // thisYearRecords.add(new UnlockRecord(44423444, new DateTime(2020, 8, 1)));
    // thisYearRecords.add(new UnlockRecord(4423444, new DateTime(2020, 8, 1)));
    // thisYearRecords.add(new UnlockRecord(44123444, new DateTime(2020, 8, 1)));
    // thisYearRecords.add(new UnlockRecord(44223444, new DateTime(2020, 8, 1)));
    // thisYearRecords.add(new UnlockRecord(45423444, new DateTime(2020, 8, 1)));
    // thisYearRecords.add(new UnlockRecord(4444444, new DateTime(2020, 8, 1)));
    // thisYearRecords.add(new UnlockRecord(4443444, new DateTime(2020, 8, 1)));
    // thisYearRecords.add(new UnlockRecord(4523444, new DateTime(2020, 8, 1)));
    // thisYearRecords.add(new UnlockRecord(4444444, new DateTime(2020, 8, 1)));
    // thisYearRecords.add(new UnlockRecord(442344, new DateTime(2020, 8, 12)));
    // thisYearRecords.add(new UnlockRecord(5551255, new DateTime(2020, 8, 15)));
    // thisYearRecords.add(new UnlockRecord(55512555, new DateTime(2020, 8, 17)));
    // thisYearRecords.add(new UnlockRecord(55761255, new DateTime(2020, 9, 17)));
    // thisYearRecords.add(new UnlockRecord(5765511, new DateTime(2020, 10, 17)));
    // thisYearRecords.add(new UnlockRecord(9999, new DateTime(2020, 11, 17)));
    // thisYearRecords.add(new UnlockRecord(939, new DateTime(2020, 12, 17)));
    return groupBy(thisYearRecords, (UnlockRecord obj) => obj.timestamp.month);
  }
  return Map<int, List<UnlockRecord>>();
}

List<PhoneUnlocks> buildMonthSeries(List<UnlockRecord> unlockData) {
  List<PhoneUnlocks> data = new List<PhoneUnlocks>();
  var thisMonthRecords = getThisMonthRecords(unlockData);
  var lastDayOfTheMonth = lastDayOfMonth(DateTime.now()).day;
  for (var i = 0; i < lastDayOfTheMonth; i++) {
    int counts = 0;
    if (thisMonthRecords.length - i <= 0) {
      continue;
    }

    counts = thisMonthRecords[thisMonthRecords.keys.elementAt(i)].length;
    data.add(new PhoneUnlocks(
        DateTime.parse(thisMonthRecords.keys.elementAt(i)), counts));
  }
  return data;
}

DateTime lastDayOfMonth(DateTime month) {
  var beginningNextMonth = (month.month < 12)
      ? new DateTime(month.year, month.month + 1, 1)
      : new DateTime(month.year + 1, 1, 1);
  return beginningNextMonth.subtract(new Duration(days: 1));
}

Map<String, List<UnlockRecord>> getThisMonthRecords(List<UnlockRecord> record) {
  var groupedRecords =
      groupBy(record, (UnlockRecord obj) => (obj.timestamp.month));
  var thisMonth = DateTime.now().month;
  if (groupedRecords.containsKey(thisMonth)) {
    var thisMonthRecords = groupedRecords[thisMonth];
    return groupBy(thisMonthRecords,
        (UnlockRecord obj) => getStringFromDate(obj.timestamp));
  }
  return Map<String, List<UnlockRecord>>();
}

List<PhoneUnlocks> buildWeekSeries(List<UnlockRecord> unlockData) {
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

Map<String, List<UnlockRecord>> getThisWeekRecords(List<UnlockRecord> record) {
  var groupedRecords =
      groupBy(record, (UnlockRecord obj) => weekNumber(obj.timestamp));
  var thisWeek = weekNumber(DateTime.now());
  if (groupedRecords.containsKey(thisWeek)) {
    var thisWeekRecords = groupedRecords[thisWeek];
    return groupBy(thisWeekRecords,
        (UnlockRecord obj) => getStringFromDate(obj.timestamp));
  }
  return Map<String, List<UnlockRecord>>();
}

List<PhoneUnlocks> buildTodaySeries(List<UnlockRecord> unlockData) {
  List<PhoneUnlocks> data = new List<PhoneUnlocks>();
  var todayRecords = getTodayRecords(unlockData);
  for (var key in todayRecords.keys) {
    var date = new DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, key);
    data.add(new PhoneUnlocks(date, todayRecords[key].length));
  }
  return data;
}

Map<int, List<UnlockRecord>> getTodayRecords(List<UnlockRecord> records) {
  var groupedRecords =
      groupBy(records, (UnlockRecord obj) => getStringFromDate(obj.timestamp));
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  var today = formatter.format(DateTime.now());
  if (groupedRecords.containsKey(today)) {
    return groupBy(
        groupedRecords[today], (UnlockRecord obj) => obj.timestamp.hour);
  }
  return Map<int, List<UnlockRecord>>();
}

int weekNumber(DateTime date) {
  int dayOfYear = int.parse(DateFormat("D").format(date));
  return ((dayOfYear - date.weekday + 10) / 7).floor();
}
