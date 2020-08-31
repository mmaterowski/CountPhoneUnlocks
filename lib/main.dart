import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'Player.dart';

void main() {
  runApp(MyApp());
}

class PhoneUnlocks {
  final String day;
  final int clicks;
  final charts.Color color;

  PhoneUnlocks(this.day, this.clicks, Color color)
      : this.color = charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepPurple,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

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
      count = 2;
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
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have unlocked the phone this many times today:'),
            Text('$_recordCount', style: Theme.of(context).textTheme.display1),
            chartWidget,
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getRecordsCount,
        tooltip: 'Get recent value',
        child: Icon(Icons.add),
      ),
    );
  }
}
