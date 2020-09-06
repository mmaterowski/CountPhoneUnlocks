import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rHabbit/widgets/app-title.dart';
import 'package:rHabbit/widgets/bottom-navigation.dart';
import 'package:rHabbit/widgets/count-section.dart';
import 'package:rHabbit/widgets/drawer.dart';
import 'package:rHabbit/widgets/profile-picture.dart';
import 'package:rHabbit/widgets/unlocks-chart.dart';
import 'models/player.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = const MethodChannel('UserActiveChannel');
  int _recordCount = 0;
  List<Player> _unlockData;

  Future<void> _getRecordsCount() async {
    int count;
    List<Player> unlockData;

    try {
      var result = await platform.invokeMethod('getCount');
      List<dynamic> playerMap = json.decode(result);
      List<Player> players =
          playerMap.map((player) => Player.fromJson(player)).toList();
      unlockData = players;
      count = 35;
    } on PlatformException catch (e) {
      log(e.toString());
    }

    setState(() {
      _recordCount = count;
      _unlockData = unlockData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          actions: [ProfilePicture.build()], title: AppTitle.build(context)),
      drawer: RHabbitDrawer.build(context),
      bottomNavigationBar: RhabbitBottomNavigation.build(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CountSection.build(context, _recordCount),
            UnlocksChart.buildChart(_unlockData),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: _getRecordsCount,
        tooltip: 'Get recent value',
        child: Icon(Icons.add),
      ),
    );
  }
}
