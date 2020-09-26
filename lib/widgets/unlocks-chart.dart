import 'package:charts_flutter/flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rHabbit/models/chart-type.dart';
import 'package:rHabbit/models/rhabbit-state.dart';
import 'package:rHabbit/models/unlock-record.dart';
import 'package:rHabbit/services/axis-builder-service.dart';
import 'package:rHabbit/services/chart-data-service.dart';
import 'package:rHabbit/services/display-period-service.dart';
import 'package:rHabbit/services/unlock-records-service.dart';
import 'package:rHabbit/utils/date-time-utils.dart';
import 'package:rHabbit/utils/debouncer.dart';
import '../models/phone-unlocks.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'custom-circle-symbol-renderer.dart';

class UnlocksChart extends StatefulWidget {
  final List<UnlockRecord> unlockData;
  final ChartType chartType;
  final RhabbitState state;
  final Function(RhabbitState) setRhabbitStateCallback;
  final UnlockRecordsService service = UnlockRecordsService();
  final DisplayPeriodService displayService = DisplayPeriodService();
  final ChartDataService chartDataService = ChartDataService();
  final _debouncer = Debouncer(milliseconds: 250);

  UnlocksChart({
    Key key,
    this.unlockData,
    this.chartType,
    this.state,
    this.setRhabbitStateCallback,
  }) : super(key: key) {
    this.service.setData(this.unlockData);
    this.chartDataService.setService(this.service);
  }

  @override
  _UnlocksChartState createState() => _UnlocksChartState();
}

class _UnlocksChartState extends State<UnlocksChart> {
  bool _isThereDataMoreDataInFuture = false;
  bool _isThereDataMoreDataInPast = true;

  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    setPagination();
  }

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

  void setPagination() {
    bool nextEnabled = false;
    bool previousEnabled = true;
    var unlockService = widget.service;

    switch (this.widget.chartType) {
      case ChartType.day:
        nextEnabled = unlockService.isThereMoreRecordsAfter(
            widget.state.getDate().add(Duration(days: 1)));
        previousEnabled =
            unlockService.isThereMoreRecordsBefore(widget.state.getDate());

        break;
      case ChartType.week:
        var endOfThisWeek = getDateByWeekNumber(
            widget.state.getWeek(), widget.state.getYear(),
            start: false);
        nextEnabled = unlockService.isThereMoreRecordsAfter(endOfThisWeek);

        var startOfThisWeek = getDateByWeekNumber(
            widget.state.getWeek(), widget.state.getYear(),
            start: true);
        previousEnabled =
            unlockService.isThereMoreRecordsBefore(startOfThisWeek);
        break;
      case ChartType.month:
        nextEnabled = unlockService
            .isThereMoreRecordsAfter(lastDayOfMonth(widget.state.getDate()));
        previousEnabled = unlockService.isThereMoreRecordsBefore(
            new DateTime(this.widget.state.getYear(), widget.state.getMonth()));
        break;
      case ChartType.year:
        nextEnabled = widget.service
            .isThereMoreRecordsAfter(getLastDayOfYear(widget.state.getYear()));
        previousEnabled = widget.service
            .isThereMoreRecordsBefore(new DateTime(widget.state.getYear()));
        break;
      default:
        nextEnabled = false;
        previousEnabled = false;
    }

    setState(() {
      _isThereDataMoreDataInFuture = nextEnabled;
      _isThereDataMoreDataInPast = previousEnabled;
    });
  }

  void setForDay(bool increase) {
    increase
        ? widget.state.add(Duration(days: 1))
        : widget.state.subtract(Duration(days: 1));
    this.widget.setRhabbitStateCallback(widget.state);

    setPagination();
  }

  setForWeek(bool increase) {
    int newWeekNumber =
        increase ? widget.state.getWeek() + 1 : widget.state.getWeek() - 1;

    widget.state.setWeek(newWeekNumber);
    widget.setRhabbitStateCallback(widget.state);
    setPagination();
  }

  setForYear(bool increase) {
    var newYear =
        increase ? widget.state.getYear() + 1 : widget.state.getYear() - 1;
    widget.state.setYear(newYear);
    this.widget.setRhabbitStateCallback(widget.state);

    setPagination();
  }

  setForMonth(bool increase) {
    increase ? widget.state.addMonth() : widget.state.subtractMonth();
    this.widget.setRhabbitStateCallback(widget.state);

    setPagination();
  }

  @override
  Widget build(BuildContext context) {
    List<PhoneUnlocks> data =
        widget.chartDataService.buildChartData(widget.chartType, widget.state);
    List<charts.Series<PhoneUnlocks, DateTime>> series = createSeries(data);
    var axisBuilder = new AxisBuilderService();
    TimeSeriesChart chart = charts.TimeSeriesChart(series,
        defaultRenderer: new charts.BarRendererConfig<DateTime>(),
        domainAxis: axisBuilder.buildAxisSpec(widget.chartType, widget.state),
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
            widget.displayService.getRawPeriod(widget.chartType, widget.state),
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
}
