import 'package:flutter/material.dart';

class RhabbitBottomNavigation {
  static build() {
    return BottomNavigationBar(items: const <BottomNavigationBarItem>[
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
    ]);
  }
}

class BuilderContext {}
