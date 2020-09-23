import 'package:charts_flutter/flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rHabbit/models/chart-type.dart';
import 'package:rHabbit/models/rhabbit-state.dart';
import 'package:rHabbit/models/unlock-record.dart';
import 'package:rHabbit/services/unlock-records-service.dart';
import 'package:rHabbit/utils/date-time-utils.dart';
import '../models/phone-unlocks.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'custom-circle-symbol-renderer.dart';

class UnlocksChart extends StatefulWidget {
  final List<UnlockRecord> unlockData;
  final ChartType chartType;
  final RhabbitState state;
  final Function(RhabbitState) setRhabbitStateCallback;
  final UnlockRecordsService service = UnlockRecordsService();

  UnlocksChart({
    Key key,
    this.unlockData,
    this.chartType,
    this.state,
    this.setRhabbitStateCallback,
  }) : super(key: key) {
    this.service.setData(this.unlockData);
  }

  @override
  _UnlocksChartState createState() => _UnlocksChartState();
}

class _UnlocksChartState extends State<UnlocksChart> {
  bool _isThereDataMoreDataInFuture = false;
  bool _isThereDataMoreDataInPast = true;

  void setChartDisplayPeriod({bool increase}) {
    switch (this.widget.chartType) {
      case ChartType.day:
        setForDay(increase);
        break;
      case ChartType.week:
        setForWeek(increase);
        break;
      case ChartType.month:
        setForMonth(increase);
        break;
      case ChartType.year:
        setForYear(increase);
        break;
      default:
    }
  }

  setForDay(bool increase) {
    increase
        ? widget.state.add(Duration(days: 1))
        : widget.state.subtract(Duration(days: 1));
    this.widget.setRhabbitStateCallback(widget.state);

    setState(() {
      _isThereDataMoreDataInFuture =
          widget.service.isThereMoreRecordsAfter(widget.state.getDate());
      _isThereDataMoreDataInPast =
          widget.service.isThereMoreRecordsBefore(widget.state.getDate());
    });
  }

  setForYear(bool increase) {
    var newYear =
        increase ? widget.state.getYear() + 1 : widget.state.getYear() - 1;
    widget.state.setYear(newYear);
    this.widget.setRhabbitStateCallback(widget.state);

    setState(() {
      _isThereDataMoreDataInFuture =
          widget.service.isThereMoreRecordsAfter(getLastDayOfYear(newYear));
      _isThereDataMoreDataInPast =
          widget.service.isThereMoreRecordsBefore(new DateTime(newYear));
    });
  }

  setForMonth(bool increase) {
    increase ? widget.state.addMonth() : widget.state.subtractMonth();
    this.widget.setRhabbitStateCallback(widget.state);

    setState(() {
      _isThereDataMoreDataInFuture = widget.service
          .isThereMoreRecordsAfter(lastDayOfMonth(this.widget.state.getDate()));
      _isThereDataMoreDataInPast = widget.service.isThereMoreRecordsBefore(
          new DateTime(
              this.widget.state.getYear(), this.widget.state.getMonth()));
    });
  }

  setForWeek(bool increase) {
    int newWeekNumber =
        increase ? widget.state.getWeek() + 1 : widget.state.getWeek() - 1;
    bool isThereMoreDataInFuture = true;
    bool isThereMoreDataInPast = true;

    if (increase) {
      var endOfThisWeek = getDateByWeekNumber(
          weeknumber: widget.state.getWeek() + 1,
          year: DateTime.now().year,
          start: false);
      if (!widget.service.isThereMoreRecordsAfter(endOfThisWeek)) {
        isThereMoreDataInFuture = false;
      }
    } else {
      var startOfThisWeek = getDateByWeekNumber(
          weeknumber: widget.state.getWeek() - 1,
          year: DateTime.now().year,
          start: true);
      if (!widget.service.isThereMoreRecordsBefore(startOfThisWeek)) {
        isThereMoreDataInPast = false;
      }
    }

    widget.state.setWeek(newWeekNumber);
    widget.setRhabbitStateCallback(widget.state);

    setState(() {
      _isThereDataMoreDataInFuture = isThereMoreDataInFuture;
      _isThereDataMoreDataInPast = isThereMoreDataInPast;
    });
  }

  List<PhoneUnlocks> buildChartData() {
    switch (this.widget.chartType) {
      case ChartType.day:
        return buildTodaySeries();
        break;
      case ChartType.week:
        return buildWeekSeries();
        break;
      case ChartType.month:
        return buildMonthSeries();
      case ChartType.year:
        return buildYearSeries();
      default:
        return List<PhoneUnlocks>();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<PhoneUnlocks> data = buildChartData();
    List<charts.Series<PhoneUnlocks, DateTime>> series = createSeries(data);

    TimeSeriesChart chart = charts.TimeSeriesChart(series,
        defaultRenderer: new charts.BarRendererConfig<DateTime>(),
        domainAxis: buildAxisSpec(this.widget.chartType, data),
        primaryMeasureAxis: new charts.NumericAxisSpec(
            renderSpec: new charts.GridlineRendererSpec(
                labelStyle: new charts.TextStyleSpec(
                    fontSize: 13, color: charts.MaterialPalette.black),
                lineStyle: new charts.LineStyleSpec(
                    color: charts.MaterialPalette.black))),
        animate: true,
        animationDuration: new Duration(milliseconds: 400),
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
        child: Column(children: [
          SizedBox(height: 200.0, child: chart),
          Text(
            formatADate(widget.state.getDate(), "dd MMM yyy"),
            style: Theme.of(context).textTheme.caption,
            textAlign: TextAlign.center,
          ),
        ]),
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
                ? () => setChartDisplayPeriod(increase: false)
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
                  ? () => setChartDisplayPeriod(increase: true)
                  : null),
        ),
      ]),
    ]);
  }

  AxisSpec<dynamic> buildAxisSpec(ChartType type, List<PhoneUnlocks> data) {
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
      var format = widget.state.getWeek() == getWeekNumber(DateTime.now())
          ? 'EE'
          : 'dd.MM';
      tickFormatterSpec = AutoDateTimeTickFormatterSpec(
          day: TimeFormatterSpec(
        format: format,
        transitionFormat: format,
      ));
      tickProviderSpec = charts.DayTickProviderSpec(increments: [1]);
    }
    if (type == ChartType.day) {
      tickFormatterSpec = charts.AutoDateTimeTickFormatterSpec(
          hour: new charts.TimeFormatterSpec(
              format: "HH:mm", transitionFormat: "HH:mm"));
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

  List<PhoneUnlocks> buildYearSeries() {
    List<PhoneUnlocks> data = new List<PhoneUnlocks>();
    var thisYearRecords = widget.service.groupByYear(DateTime.now().year);

    for (var i = 1; i <= DateTime.monthsPerYear; i++) {
      if (thisYearRecords.containsKey(i)) {
        data.add(new PhoneUnlocks(
            new DateTime(DateTime.now().year, i), thisYearRecords[i].length));
      }
    }
    addEmtyRecordsIfNeeded(data);
    return data;
  }

  void addEmtyRecordsIfNeeded(List<PhoneUnlocks> data) {
    if (data.length == 1) {
      var date = data.first.timestamp;
      if (date.month != DateTime.december) {
        data.add(new PhoneUnlocks(new DateTime(date.year, date.month + 1), 0));
      }
      if (date.month != DateTime.january)
        data.add(new PhoneUnlocks(new DateTime(date.year, date.month - 1), 0));
    }
  }

  List<PhoneUnlocks> buildMonthSeries() {
    List<PhoneUnlocks> data = new List<PhoneUnlocks>();
    var monthRecords =
        widget.service.groupByMonth(DateTime.now().month, DateTime.now().year);
    var lastDayOfTheMonth = lastDayOfMonth(DateTime.now()).day;
    for (var i = 0; i < lastDayOfTheMonth; i++) {
      int counts = 0;
      if (monthRecords.length - i <= 0) {
        continue;
      }

      counts = monthRecords[monthRecords.keys.elementAt(i)].length;
      data.add(new PhoneUnlocks(
          DateTime.parse(monthRecords.keys.elementAt(i)), counts));
    }
    return data;
  }

  List<PhoneUnlocks> buildWeekSeries() {
    var data = new List<PhoneUnlocks>();
    var weekRecords = widget.service.groupByWeek(widget.state.getWeek());
    for (int i = 0; i < DateTime.daysPerWeek; i++) {
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

  List<PhoneUnlocks> buildTodaySeries() {
    List<PhoneUnlocks> data = new List<PhoneUnlocks>();
    var todayRecords = widget.service.groupByDay(widget.state.getDate());
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
