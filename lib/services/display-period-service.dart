import 'package:rHabbit/models/chart-type.dart';
import 'package:rHabbit/models/rhabbit-state.dart';
import 'package:rHabbit/utils/date-time-utils.dart';

class DisplayPeriodService {
  String getPeriod(ChartType chartType, RhabbitState state) {
    switch (chartType) {
      case ChartType.day:
        return day(state.getDate());
      case ChartType.week:
        return week(state);
      case ChartType.month:
        return 'this month';
      case ChartType.year:
        return 'this year';
      default:
        return '???';
    }
  }

  String getRawPeriod(ChartType chartType, RhabbitState state) {
    switch (chartType) {
      case ChartType.day:
        return formatADate(state.getDate(), 'dd MMM yyyy');
      case ChartType.week:
        return weekRaw(state);
      case ChartType.month:
        return state.getMonthName() + ' ' + state.getYear().toString();
      case ChartType.year:
        return state.getYear().toString();
      default:
        return '???';
    }
  }

  String day(DateTime date) {
    if (DateTime.now().day == date.day) {
      return 'today';
    }
    if (DateTime.now().day - 1 == date.day) {
      return 'yesterday';
    }
    return 'at ' + formatADate(date, 'dd MMM yyyy');
  }

  String dayRaw(DateTime date) {
    return formatADate(date, 'dd MMM yyyy');
  }

  String week(RhabbitState state) {
    var thisWeekNumber = getWeekNumber(DateTime.now());

    if (thisWeekNumber == state.getWeek()) {
      return 'this week';
    }
    if (thisWeekNumber - 1 == state.getWeek()) {
      return 'last week';
    }
    return 'between \n' + weekRaw(state);
  }

  String weekRaw(RhabbitState state) {
    var weekStart = getDateByWeekNumber(
        weeknumber: state.getWeek(), year: state.getYear(), start: true);
    var weekEnd = getDateByWeekNumber(
        weeknumber: state.getWeek(), year: state.getYear(), start: false);
    var formattedWeekStart = formatADate(weekStart, 'd MMM');
    var formattedWeekEnd = formatADate(weekEnd, 'd MMM yyyy');
    return formattedWeekStart + " - " + formattedWeekEnd;
  }
}
