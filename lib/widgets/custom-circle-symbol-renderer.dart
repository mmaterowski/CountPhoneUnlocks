import 'dart:math';
import 'package:charts_flutter/src/text_element.dart' as ChartText;
import 'package:charts_flutter/src/text_style.dart' as ChartStyle;
import 'package:charts_flutter/flutter.dart';

String _title;

String _subTitle;

class ToolTipMgr {
  static String get title => _title;

  static String get subTitle => _subTitle;

  static setTitle(Map<String, dynamic> data) {
    if (data['title'] != null && data['title'].length > 0) {
      _title = data['title'];
    }

    if (data['subTitle'] != null && data['subTitle'].length > 0) {
      _subTitle = data['subTitle'];
    }
  }
}

class CustomCircleSymbolRenderer extends CircleSymbolRenderer {
  @override
  void paint(ChartCanvas canvas, Rectangle<num> bounds,
      {List<int> dashPattern,
      Color fillColor,
      FillPatternType fillPattern,
      Color strokeColor,
      double strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);
    // canvas.drawRect(
    //     Rectangle(bounds.left - 5, bounds.top - 30, bounds.width + 100,
    //         bounds.height + 10),
    //     fill: new Color(r: 254, g: 234, b: 230));
    double radius = 15;
    if (ToolTipMgr.title.length == 4) {
      radius = 30;
    }
    canvas.drawCircleSector(
        new Point(bounds.left + 4, bounds.top - 20), 0, radius, 0, 6.283,
        fill: new Color(r: 254, g: 234, b: 230));
    ChartStyle.TextStyle textStyle = ChartStyle.TextStyle();
    textStyle.color = Color.black;
    textStyle.fontSize = 15;
    textStyle.fontFamily = "Rubik";

    num offset = 0;
    if (ToolTipMgr.title.length == 2) {
      offset = 4.5;
    }
    if (ToolTipMgr.title.length == 3) {
      offset = 8.5;
    }
    canvas.drawText(ChartText.TextElement(ToolTipMgr.title, style: textStyle),
        (bounds.left - offset).round(), (bounds.top - 26).round());
  }
}
