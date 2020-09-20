import 'dart:convert';
import 'dart:developer';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rHabbit/utils/date-time-utils.dart';
import 'package:rHabbit/widgets/app-title.dart';
import 'package:rHabbit/widgets/bottom-navigation.dart';
import 'package:rHabbit/widgets/count-section.dart';
import 'package:rHabbit/widgets/drawer.dart';
import 'package:rHabbit/widgets/profile-picture.dart';
import 'package:rHabbit/widgets/stats-section.dart';
import 'package:rHabbit/widgets/unlocks-chart.dart';
import 'package:swipedetector/swipedetector.dart';

import 'models/chart-type.dart';
import 'models/unlock-record.dart';

class MyHomePage extends StatefulWidget {
  static const String routeName = "/home";

  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = const MethodChannel('UserActiveChannel');
  int _recordCount = 0;
  List<UnlockRecord> _unlockData = new List<UnlockRecord>();
  ChartType _chartType = ChartType.day;
  int _weekNumber = getWeekNumber(DateTime.now());
  bool _isThereDataMoreData = true;

  @override
  void initState() {
    super.initState();
    callbackAfterInit(_getRecordsCount);
  }

  Future<void> _getRecordsCount() async {
    int count = 0;
    List<UnlockRecord> unlockData;

    try {
      var result = await platform.invokeMethod('getCount');
      List<dynamic> recordsMap = json.decode(result);
      List<UnlockRecord> unlockRecords =
          recordsMap.map((record) => UnlockRecord.fromJson(record)).toList();
      unlockData = unlockRecords;
      count = getTodayCount(unlockRecords);
    } on PlatformException catch (e) {
      log(e.toString());
    }

    setState(() {
      _recordCount = count;
      _unlockData = unlockData;
    });
  }

  callbackAfterInit(Function method) {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => _getRecordsCount());
    }
  }

  void onSwipeRight() {
    ChartType type;
    var numberOfEnums = ChartType.values.length;
    var indexOfCurrentValue = _chartType.index;
    if (indexOfCurrentValue < numberOfEnums - 1) {
      type = ChartType.values[indexOfCurrentValue + 1];
    } else {
      type = _chartType;
    }

    setState(() {
      _chartType = type;
    });
  }

  void onSwipeLeft() {
    ChartType type;
    var indexOfCurrentValue = _chartType.index;
    if (indexOfCurrentValue == 0) {
      type = _chartType;
    } else {
      type = ChartType.values[indexOfCurrentValue - 1];
    }

    setState(() {
      _chartType = type;
    });
  }

  void setWeekNumber({bool increase}) {
    int newWeekNumber = increase ? _weekNumber + 1 : _weekNumber - 1;
    setState(() {
      _weekNumber = newWeekNumber;
    });
  }

  void isThereMoreDataToDisplay(bool isThere) {
    setState(() {
      _isThereDataMoreData = isThere;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
              actions: [
                new ProfilePicture(
                    pictureUrl: 'assets/images/profile-picture.jpg')
              ],
              bottom: TabBar(
                tabs: [
                  Tab(text: "TODAY"),
                  Tab(text: "WEEK"),
                  Tab(text: "MONTH"),
                  Tab(text: "YEAR"),
                ],
              ),
              title: new AppTitle()),
          drawer: new RHabbitDrawer(),
          bottomNavigationBar: RhabbitBottomNavigation.build(),
          body: SwipeDetector(
            onSwipeRight: onSwipeRight,
            onSwipeLeft: onSwipeLeft,
            child: TabBarView(children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new CountSection(
                      unlockData: _unlockData,
                      chartType: ChartType.day,
                    ),
                    new UnlocksChart(
                        unlockData: _unlockData, chartType: ChartType.day),
                    // new StatsSection(averageUnlockCount: _recordCount - 10)
                  ],
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new CountSection(
                      unlockData: _unlockData,
                      chartType: ChartType.week,
                    ),
                    new UnlocksChart(
                        unlockData: _unlockData,
                        chartType: ChartType.week,
                        weekNumber: _weekNumber,
                        callback: isThereMoreDataToDisplay),
                    // new StatsSection(averageUnlockCount: _recordCount - 10)
                  ],
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new CountSection(
                      unlockData: _unlockData,
                      chartType: ChartType.month,
                    ),
                    new UnlocksChart(
                      unlockData: _unlockData,
                      chartType: ChartType.month,
                    ),
                    // new StatsSection(averageUnlockCount: _recordCount - 10)
                  ],
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new CountSection(
                      unlockData: _unlockData,
                      chartType: ChartType.year,
                    ),
                    new UnlocksChart(
                      unlockData: _unlockData,
                      chartType: ChartType.year,
                    ),
                    // new StatsSection(averageUnlockCount: _recordCount - 10)
                  ],
                ),
              ),
            ]),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ));
  }
}

void fetchDataFromBackend() {}

int getTodayCount(List<UnlockRecord> records) {
  var groupedRecords =
      groupBy(records, (UnlockRecord obj) => getStringFromDate(obj.timestamp));
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  var today = formatter.format(DateTime.now());
  if (groupedRecords.containsKey(today)) {
    return groupedRecords[today].length;
  }
  return 0;
}

String getStringFromDate(DateTime dateTime) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(dateTime);
}
