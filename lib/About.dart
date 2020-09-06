import 'package:flutter/material.dart';
import 'package:rHabbit/widgets/drawer.dart';

class About extends StatelessWidget {
  static const String routeName = '/about';

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text("About"),
        ),
        drawer: RHabbitDrawer(),
        body: Center(child: Text("ABOUT")));
  }
}
