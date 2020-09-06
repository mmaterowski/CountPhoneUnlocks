import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'models/phone-unlocks.dart';
import 'models/player.dart';
import 'extensions/iterableExtension.dart';
import 'package:rHabbit/styles/my_flutter_app_icons.dart' as AppIcon;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = const MethodChannel('UserActiveChannel');
  int _recordCount = 0;

  Future<void> _getRecordsCount() async {
    int count;
    try {
      var result = await platform.invokeMethod('getCount');
      List<dynamic> playerMap = json.decode(result);
      List<Player> players =
          playerMap.map((player) => Player.fromJson(player)).toList();

      var dayMap = players.groupBy((p) => p.timestamp);
      count = 35;
    } on PlatformException catch (e) {
      log(e.toString());
    }

    setState(() {
      _recordCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    var data = [
      PhoneUnlocks('Last week', 26, Colors.blue),
      PhoneUnlocks('Yesterday', 12, Colors.red),
      PhoneUnlocks('Today', _recordCount, Colors.green),
    ];

    var series = [
      charts.Series(
        domainFn: (PhoneUnlocks clickData, _) => clickData.day,
        measureFn: (PhoneUnlocks clickData, _) => clickData.clicks,
        colorFn: (PhoneUnlocks clickData, _) => clickData.color,
        id: 'Clicks',
        data: data,
      ),
    ];

    var chart = charts.BarChart(
      series,
      animate: true,
    );

    var chartWidget = Padding(
      padding: EdgeInsets.all(32.0),
      child: SizedBox(
        height: 200.0,
        child: chart,
      ),
    );

    return Scaffold(
      appBar: AppBar(
          actions: [
            Material(
              elevation: 4.0,
              shape: CircleBorder(),
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: Ink.image(
                image: AssetImage('assets/images/profile-picture.jpg'),
                fit: BoxFit.contain,
                width: 80.0,
                height: 80.0,
                child: InkWell(
                  onTap: () {},
                ),
              ),
            )
          ],
          title: RichText(
            text: TextSpan(
              children: [
                WidgetSpan(
                    child: Icon(
                  AppIcon.MyFlutterApp.app_icon,
                  size: 25,
                )),
                TextSpan(
                    text: " rHabbit",
                    style: Theme.of(context).textTheme.headline5),
              ],
            ),
          )),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'Drawer Header',
                style: Theme.of(context).textTheme.headline5,
              ),
              // decoration: BoxDecoration(
              // color: Colors.blue,
              // ),
            ),
            ListTile(
              title:
                  Text('Item 1', style: Theme.of(context).textTheme.headline6),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                'Item 2',
                style: Theme.of(context).textTheme.headline6,
              ),
              onTap: () {
                // Update the state of the app.
                // ...
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          BottomNavigationBar(items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          title: Text('My day'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up),
          title: Text('Stats'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.wb_incandescent),
          title: Text('Tips'),
        ),
      ]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have unlocked the phone this many times today:',
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('$_recordCount',
                    style: Theme.of(context).textTheme.headline4)),
            chartWidget,
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
