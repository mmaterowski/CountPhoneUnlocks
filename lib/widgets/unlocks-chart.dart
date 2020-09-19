import 'package:charts_flutter/flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:collection/collection.dart";
import 'package:rHabbit/models/chart-type.dart';
import 'package:rHabbit/models/unlock-record.dart';
import 'package:rHabbit/services/unlock-records-service.dart';
import 'package:rHabbit/utils/date-time-utils.dart';
import '../models/phone-unlocks.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'custom-circle-symbol-renderer.dart';

class UnlocksChart extends StatefulWidget {
  final List<UnlockRecord> unlockData;
  final ChartType chartType;
  final int weekNumber;
  final Function(bool) callback;
  final UnlockRecordsService service = UnlockRecordsService();

  UnlocksChart({
    Key key,
    this.unlockData,
    this.chartType,
    this.weekNumber,
    this.callback,
  }) : super(key: key) {
    this.service.setData(this.unlockData);
  }

  @override
  _UnlocksChartState createState() => _UnlocksChartState();
}

class _UnlocksChartState extends State<UnlocksChart> {
  int _currentWeekNumber;
  bool _isThereDataMoreDataInFuture = false;
  bool _isThereDataMoreDataInPast = true;

  @override
  void initState() {
    super.initState();
    _currentWeekNumber = this.widget.weekNumber;
  }

  void setWeekNumber({bool increase}) {
    int newWeekNumber =
        increase ? _currentWeekNumber + 1 : _currentWeekNumber - 1;
    bool isThereMoreDataInFuture = true;
    bool isThereMoreDataInPast = true;

    if (increase) {
      var endOfThisWeek = getDateByWeekNumber(
          weeknumber: _currentWeekNumber + 1,
          year: DateTime.now().year,
          start: false);
      if (!this.widget.service.isThereMoreRecordsAfter(endOfThisWeek)) {
        isThereMoreDataInFuture = false;
      }
    } else {
      var startOfThisWeek = getDateByWeekNumber(
          weeknumber: _currentWeekNumber - 1,
          year: DateTime.now().year,
          start: true);
      if (!this.widget.service.isThereMoreRecordsBefore(startOfThisWeek)) {
        isThereMoreDataInPast = false;
      }
    }

    setState(() {
      _currentWeekNumber = newWeekNumber;
      _isThereDataMoreDataInFuture = isThereMoreDataInFuture;
      _isThereDataMoreDataInPast = isThereMoreDataInPast;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<PhoneUnlocks> data = new List<PhoneUnlocks>();
    charts.TimeSeriesChart chart;
    if (this.widget.chartType == ChartType.today) {
      data = buildTodaySeries(this.widget.unlockData);
    }
    if (this.widget.chartType == ChartType.week) {
      data = buildWeekSeries(
          this.widget.unlockData, this.widget.callback, _currentWeekNumber);
    }
    if (this.widget.chartType == ChartType.month) {
      data = buildMonthSeries(this.widget.unlockData);
    }
    if (this.widget.chartType == ChartType.year) {
      data = buildYearSeries(this.widget.unlockData);
    }
    var series = createSeries(data);

    chart = charts.TimeSeriesChart(series,
        defaultRenderer: new charts.BarRendererConfig<DateTime>(),
        domainAxis:
            buildAxisSpec(this.widget.chartType, data, this.widget.weekNumber),
        primaryMeasureAxis: new charts.NumericAxisSpec(
            renderSpec: new charts.GridlineRendererSpec(
                labelStyle: new charts.TextStyleSpec(
                    fontSize: 13, color: charts.MaterialPalette.black),
                lineStyle: new charts.LineStyleSpec(
                    color: charts.MaterialPalette.black))),
        animate: true,
        animationDuration: new Duration(milliseconds: 500),
        defaultInteractions: false,
        selectionModels: [
          charts.SelectionModelConfig(
              changedListener: (charts.SelectionModel model) {
            if (model.hasDatumSelection) {
              ToolTipMgr.setTitle(
                  {'title': '${model.selectedDatum[0].datum.clicks}'});
            }
          })
        ],
        behaviors: [
          new charts.DomainHighlighter(),
          new charts.LinePointHighlighter(
              symbolRenderer: CustomCircleSymbolRenderer()),
          new charts.SelectNearest(
              eventTrigger: charts.SelectionTrigger.tapAndDrag)
        ]);

    return Column(children: [
      Padding(
        padding: EdgeInsets.all(32.0),
        child: SizedBox(
          height: 200.0,
          child: chart,
        ),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        ButtonTheme(
          textTheme: Theme.of(context).buttonTheme.textTheme,
          colorScheme: Theme.of(context).colorScheme,
          buttonColor: Theme.of(context).textSelectionColor,
          disabledColor: Theme.of(context).disabledColor,
          minWidth: 130.0,
          height: 40.0,
          child: RaisedButton(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.arrow_back_ios),
                  Text("Previous")
                ]),
            elevation: 2.0,
            autofocus: false,
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(26 / 1.5)),
            onPressed: _isThereDataMoreDataInPast
                ? () => setWeekNumber(increase: false)
                : null,
          ),
        ),
        ButtonTheme(
          textTheme: Theme.of(context).buttonTheme.textTheme,
          colorScheme: Theme.of(context).colorScheme,
          buttonColor: Theme.of(context).textSelectionColor,
          minWidth: 130.0,
          height: 40.0,
          child: RaisedButton(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("Next"),
                    Icon(Icons.arrow_forward_ios),
                  ]),
              elevation: 2.0,
              autofocus: false,
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(26 / 1.5)),
              onPressed: _isThereDataMoreDataInFuture
                  ? () => setWeekNumber(increase: true)
                  : null),
        ),
      ]),
    ]);
  }

  AxisSpec<dynamic> buildAxisSpec(
      ChartType type, List<PhoneUnlocks> data, int numberOfTheWeek) {
    RenderSpec<DateTime> renderSpec = new charts.SmallTickRendererSpec(
        minimumPaddingBetweenLabelsPx: 0,
        labelStyle: new charts.TextStyleSpec(
            fontSize: 12, color: charts.MaterialPalette.black),
        lineStyle:
            new charts.LineStyleSpec(color: charts.MaterialPalette.black));

    AutoDateTimeTickFormatterSpec tickFormatterSpec;
    DateTimeTickProviderSpec tickProviderSpec;

    if (type == ChartType.year) {
      tickFormatterSpec = AutoDateTimeTickFormatterSpec(
          month: TimeFormatterSpec(
        format: 'MMM',
        transitionFormat: 'MMM',
      ));
    }

    if (type == ChartType.month) {
      tickFormatterSpec = AutoDateTimeTickFormatterSpec(
          day: TimeFormatterSpec(
        format: 'dd.MM',
        transitionFormat: 'dd.MM',
      ));
    }

    if (type == ChartType.week) {
      var format =
          numberOfTheWeek == getWeekNumber(DateTime.now()) ? 'EE' : 'dd.MM';
      tickFormatterSpec = AutoDateTimeTickFormatterSpec(
          day: TimeFormatterSpec(
        format: format,
        transitionFormat: format,
      ));
      tickProviderSpec = charts.DayTickProviderSpec(increments: [1]);
    }
    if (type == ChartType.today) {
      tickFormatterSpec = charts.AutoDateTimeTickFormatterSpec(
          hour: new charts.TimeFormatterSpec(
              format: "HH:mm", transitionFormat: "HH:mm"));
      renderSpec = new charts.SmallTickRendererSpec();
    }

    return charts.DateTimeAxisSpec(
        renderSpec: renderSpec,
        tickFormatterSpec: tickFormatterSpec,
        tickProviderSpec: tickProviderSpec);
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

  Map<int, List<UnlockRecord>> getThisYearRecords(List<UnlockRecord> records) {
    var groupedRecords =
        groupBy(records, (UnlockRecord obj) => (obj.timestamp.year));
    var thisYear = DateTime.now().year;
    if (groupedRecords.containsKey(thisYear)) {
      var thisYearRecords = groupedRecords[thisYear];
      return groupBy(
          thisYearRecords, (UnlockRecord obj) => obj.timestamp.month);
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

  Map<String, List<UnlockRecord>> getThisMonthRecords(
      List<UnlockRecord> records) {
    var groupedRecords =
        groupBy(records, (UnlockRecord obj) => (obj.timestamp.month));
    var thisMonth = DateTime.now().month;
    if (groupedRecords.containsKey(thisMonth)) {
      var thisMonthRecords = groupedRecords[thisMonth];
      return groupBy(thisMonthRecords,
          (UnlockRecord obj) => getStringFromDate(obj.timestamp));
    }
    return Map<String, List<UnlockRecord>>();
  }

  List<PhoneUnlocks> buildWeekSeries(List<UnlockRecord> unlockData,
      Function(bool) onPreviousClick, int numberOfWeek) {
    var data = new List<PhoneUnlocks>();
    var weekRecords = this.widget.service.groupByWeek(numberOfWeek);
    for (var i = 0; i < 7; i++) {
      if (shouldAddEmptyDay(weekRecords, data, i)) {
        addEmptyDayRecordOnNextDay(data);
        continue;
      }
      addDayRecord(weekRecords, data, i);
    }
    return data;
  }

  bool shouldAddEmptyDay(Map<String, List<UnlockRecord>> weekRecords,
      List<PhoneUnlocks> data, int i) {
    bool noMoreRecordsToIterate = weekRecords.length - i <= 0;
    return noMoreRecordsToIterate && data.length != 0;
  }

  void addEmptyDayRecordOnNextDay(List<PhoneUnlocks> data) {
    var nextDay = data.last.timestamp.add(new Duration(days: 1));
    data.add(new PhoneUnlocks(nextDay, 0));
  }

  void addDayRecord(Map<String, List<UnlockRecord>> weekRecords,
      List<PhoneUnlocks> data, int i) {
    var counts = weekRecords[weekRecords.keys.elementAt(i)].length;
    data.add(new PhoneUnlocks(
        DateTime.parse(weekRecords.keys.elementAt(i)), counts));
  }

  Map<String, List<UnlockRecord>> getWeekRecords(List<UnlockRecord> records,
      [int numberOfWeek]) {
    var groupedRecords =
        groupBy(records, (UnlockRecord obj) => getWeekNumber(obj.timestamp));
    if (groupedRecords.containsKey(numberOfWeek)) {
      var thisWeekRecords = groupedRecords[numberOfWeek];
      return groupBy(thisWeekRecords,
          (UnlockRecord obj) => getStringFromDate(obj.timestamp));
    }
    return Map<String, List<UnlockRecord>>();
  }

  List<PhoneUnlocks> buildTodaySeries(List<UnlockRecord> unlockData) {
    List<PhoneUnlocks> data = new List<PhoneUnlocks>();
    var todayRecords = this.widget.service.groupByDay(DateTime.now());
    for (var key in todayRecords.keys) {
      var date = new DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, key);
      data.add(new PhoneUnlocks(date, todayRecords[key].length));
    }

    if (data.length <= 2) {
      var lastRecord = data.last.timestamp;
      if (lastRecord.hour < 24) {
        var nextHour = new DateTime(lastRecord.year, lastRecord.month,
            lastRecord.day, lastRecord.hour + 1);
        data.add(new PhoneUnlocks(nextHour, 0));
      }
    }
    return data;
  }
}
