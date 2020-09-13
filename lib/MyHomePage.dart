import 'dart:convert';
import 'dart:developer';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rHabbit/widgets/app-title.dart';
import 'package:rHabbit/widgets/bottom-navigation.dart';
import 'package:rHabbit/widgets/count-section.dart';
import 'package:rHabbit/widgets/drawer.dart';
import 'package:rHabbit/widgets/profile-picture.dart';
import 'package:rHabbit/widgets/stats-section.dart';
import 'package:rHabbit/widgets/unlocks-chart.dart';

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
  ChartType _chartType = ChartType.today;

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

  void onSwipe(DragUpdateDetails details) {
    ChartType type;
    if (details.delta.dx > 0) {
      type = ChartType.week;
    }

    if (details.delta.dx < 0) {
      type = ChartType.today;
    }

    setState(() {
      _chartType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        new ProfilePicture(pictureUrl: 'assets/images/profile-picture.jpg')
      ], title: new AppTitle()),
      drawer: new RHabbitDrawer(),
      bottomNavigationBar: RhabbitBottomNavigation.build(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new CountSection(
              recordCount: _recordCount,
            ),
            GestureDetector(
              onPanUpdate: onSwipe,
              child: new UnlocksChart(
                unlockData: _unlockData,
                chartType: _chartType,
              ),
            ),
            new StatsSection(averageUnlockCount: _recordCount - 10)
          ],
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
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
