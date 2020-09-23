import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rHabbit/models/chart-type.dart';
import 'package:rHabbit/models/rhabbit-state.dart';
import 'package:rHabbit/models/unlock-record.dart';
import 'package:rHabbit/services/unlock-records-service.dart';
import 'package:rHabbit/utils/date-time-utils.dart';
import 'package:rHabbit/widgets/animated-count.dart';

class CountSection extends StatefulWidget {
  final List<UnlockRecord> unlockData;
  final ChartType chartType;
  final RhabbitState state;
  final UnlockRecordsService service = UnlockRecordsService();

  @override
  CountSection({Key key, this.unlockData, this.chartType, this.state})
      : super(key: key) {
    this.service.setData(this.unlockData);
  }

  @override
  _CountSectionState createState() => _CountSectionState();
}

class _CountSectionState extends State<CountSection> {
  String _getText(ChartType chartType) {
    switch (chartType) {
      case ChartType.day:
        if (DateTime.now().day == widget.state.getDate().day) {
          return 'today';
        }
        if (DateTime.now().day - 1 == widget.state.getDate().day) {
          return 'yesterday';
        }
        return 'at ' + formatADate(widget.state.getDate(), 'dd MMM yyyy');
      case ChartType.week:
        var thisWeekNumber = getWeekNumber(DateTime.now());
        if (thisWeekNumber == widget.state.getWeek()) {
          return 'this week';
        }
        if (thisWeekNumber - 1 == widget.state.getWeek()) {
          return 'last week';
        }
        var weekStart = getDateByWeekNumber(
            weeknumber: widget.state.getWeek(),
            year: widget.state.getYear(),
            start: true);
        var weekEnd = getDateByWeekNumber(
            weeknumber: widget.state.getWeek(),
            year: widget.state.getYear(),
            start: false);
        var formattedWeekStart = formatADate(weekStart, 'd MMM');
        var formattedWeekEnd = formatADate(weekEnd, 'd MMM yyyy');
        return 'between \n' + formattedWeekStart + " - " + formattedWeekEnd;
      case ChartType.month:
        return 'this month';
      case ChartType.year:
        return 'this year';
      default:
        return '???';
    }
  }

  int _getCount(ChartType chartType) {
    switch (chartType) {
      case ChartType.day:
        return widget.service.getTodayCount(widget.state.getDate());
      case ChartType.week:
        return widget.service.getWeekCount(widget.state.getWeek());
      case ChartType.month:
        return widget.service
            .getMonthCount(widget.state.getMonth(), widget.state.getYear());
      case ChartType.year:
        return widget.service.getYearCount(widget.state.getYear());
      default:
        return 0;
    }
  }

  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        'You have unlocked Your phone',
        style: Theme.of(context).textTheme.headline6,
        textAlign: TextAlign.center,
      ),
      Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(8),
        width: 85,
        height: 85,
        decoration: BoxDecoration(
          border: Border.all(width: 2),
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedCount(
                count: _getCount(this.widget.chartType),
                duration: Duration(milliseconds: 500))
          ],
        ),
      ),
      Text(
        'times ${_getText(this.widget.chartType)}',
        style: Theme.of(context).textTheme.headline6,
        textAlign: TextAlign.center,
      ),
    ]);
  }
}

callbackAfterInit(Function method) {
  if (SchedulerBinding.instance.schedulerPhase ==
      SchedulerPhase.persistentCallbacks) {
    SchedulerBinding.instance.addPostFrameCallback((_) => method());
  }
}
