import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class PhoneUnlocks {
  final String day;
  final int clicks;
  final charts.Color color;

  PhoneUnlocks(this.day, this.clicks, Color color)
      : this.color = charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}
