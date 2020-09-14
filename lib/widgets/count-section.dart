import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:rHabbit/models/chart-type.dart';
import 'package:rHabbit/models/unlock-record.dart';
import 'package:rHabbit/utils/date-time-utils.dart';
import 'package:rHabbit/widgets/animated-count.dart';

class CountSection extends StatefulWidget {
  final List<UnlockRecord> unlockData;
  final ChartType chartType;
  @override
  CountSection({Key key, this.unlockData, this.chartType}) : super(key: key);

  @override
  _CountSectionState createState() => _CountSectionState();
}

class _CountSectionState extends State<CountSection> {
  @override
  void initState() {
    super.initState();
  }

//MAKE WIDGET REFRESH/ANIMATE
  int _count = 0;
  String _text = '?';
  ChartType _chartType;

  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        'You have unlocked Your phone',
        style: Theme.of(context).textTheme.headline6,
        textAlign: TextAlign.center,
      ),
      Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        width: 80,
        height: 80,
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
                count: _getCount(this.widget.chartType, this.widget.unlockData),
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

String _getText(ChartType chartType) {
  switch (chartType) {
    case ChartType.today:
      return 'today';
    case ChartType.week:
      return 'this week';
    case ChartType.month:
      return 'this month';
    case ChartType.year:
      return 'this year';
    default:
      return '???';
  }
}

int _getCount(ChartType chartType, List<UnlockRecord> unlockData) {
  switch (chartType) {
    case ChartType.today:
      return getTodayCount(unlockData);
    case ChartType.week:
      return getThisWeekCount(unlockData);
    case ChartType.month:
      return getThisMonthCount(unlockData);
    case ChartType.year:
      return getThisYearCount(unlockData);
    default:
      return 0;
  }
}

int getTodayCount(List<UnlockRecord> records) {
  var groupedRecords =
      groupBy(records, (UnlockRecord obj) => getStringFromDate(obj.timestamp));
  var formatter = DateFormat('yyyy-MM-dd');
  var today = formatter.format(DateTime.now());
  if (groupedRecords.containsKey(today)) {
    return groupedRecords[today].length;
  }
  return 0;
}

int getThisWeekCount(List<UnlockRecord> records) {
  var groupedRecords =
      groupBy(records, (UnlockRecord obj) => weekNumber(obj.timestamp));
  var thisWeek = weekNumber(DateTime.now());
  if (groupedRecords.containsKey(thisWeek)) {
    return groupedRecords[thisWeek].length;
  }
  return 0;
}

int getThisMonthCount(List<UnlockRecord> records) {
  var groupedRecords =
      groupBy(records, (UnlockRecord obj) => (obj.timestamp.month));
  var thisMonth = DateTime.now().month;
  if (groupedRecords.containsKey(thisMonth)) {
    return groupedRecords[thisMonth].length;
  }
  return 0;
}

int getThisYearCount(List<UnlockRecord> records) {
  var groupedRecords =
      groupBy(records, (UnlockRecord obj) => (obj.timestamp.year));
  var thisYear = DateTime.now().year;
  if (groupedRecords.containsKey(thisYear)) {
    return groupedRecords[thisYear].length;
  }
  return 0;
}
