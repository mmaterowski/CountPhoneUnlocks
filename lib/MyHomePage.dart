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
  static const String routeName = "/home";
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = const MethodChannel('UserActiveChannel');
  int _recordCount = 0;
  List<Player> _unlockData = new List<Player>();

  Future<void> _getRecordsCount() async {
    int count;
    List<Player> unlockData;

    try {
      var result = await platform.invokeMethod('getCount');
      List<dynamic> playerMap = json.decode(result);
      List<Player> players =
          playerMap.map((player) => Player.fromJson(player)).toList();
      unlockData = players;
      count = players.length;
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
            new UnlocksChart(unlockData: _unlockData),
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
