import 'package:charts_flutter/flutter.dart';
import 'package:rHabbit/models/chart-type.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:rHabbit/models/rhabbit-state.dart';
import 'package:rHabbit/utils/date-time-utils.dart';

class AxisBuilderService {
  AxisSpec<dynamic> buildAxisSpec(ChartType type, RhabbitState state) {
    RenderSpec<DateTime> renderSpec = new charts.SmallTickRendererSpec(
        minimumPaddingBetweenLabelsPx: 0,
        labelStyle: new charts.TextStyleSpec(
            fontSize: 12, color: charts.MaterialPalette.black),
        lineStyle:
            new charts.LineStyleSpec(color: charts.MaterialPalette.black));

    AutoDateTimeTickFormatterSpec tickFormatterSpec;
    DateTimeTickProviderSpec tickProviderSpec;

    if (type == ChartType.year) {
      tickFormatterSpec = AutoDateTimeTickFormatterSpec(
          month: TimeFormatterSpec(
        format: 'MMM',
        transitionFormat: 'MMM',
      ));
    }

    if (type == ChartType.month) {
      tickFormatterSpec = AutoDateTimeTickFormatterSpec(
          day: TimeFormatterSpec(
        format: 'dd.MM',
        transitionFormat: 'dd.MM',
      ));
    }

    if (type == ChartType.week) {
      var format =
          state.getWeek() == getWeekNumber(DateTime.now()) ? 'EE' : 'dd.MM';
      tickFormatterSpec = AutoDateTimeTickFormatterSpec(
          day: TimeFormatterSpec(
        format: format,
        transitionFormat: format,
      ));
      tickProviderSpec = charts.DayTickProviderSpec(increments: [1]);
    }
    if (type == ChartType.day) {
      tickFormatterSpec = charts.AutoDateTimeTickFormatterSpec(
          hour: new charts.TimeFormatterSpec(
              format: "HH:mm", transitionFormat: "HH:mm"));
    }

    return charts.DateTimeAxisSpec(
        renderSpec: renderSpec,
        tickFormatterSpec: tickFormatterSpec,
        tickProviderSpec: tickProviderSpec);
  }
}
