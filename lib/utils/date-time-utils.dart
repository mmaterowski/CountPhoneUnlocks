import 'package:intl/intl.dart';

int getWeekNumber(DateTime date) {
  int dayOfYear = int.parse(DateFormat("D").format(date));
  return ((dayOfYear - date.weekday + 10) / 7).floor();
}

int getNumber(DateTime date) {
  int dayOfYear = int.parse(DateFormat("D").format(date));
  return ((dayOfYear - date.weekday + 10) / 7).floor();
}

String getStringFromDate(DateTime dateTime) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(dateTime);
}

String formatADate(DateTime date, String format) {
  var formatter = DateFormat(format);
  return formatter.format(date);
}

DateTime getDateByWeekNumber(int weeknumber, int year, {bool start}) {
  //check if start == true retrun start date of week
  //else return end date
  var days = ((weeknumber - 1) * 7) + (start ? 0 : 6);
  return DateTime.utc(year, 1, days);
}

DateTime lastDayOfMonth(DateTime month) {
  var beginningNextMonth = (month.month < 12)
      ? new DateTime(month.year, month.month + 1, 1)
      : new DateTime(month.year + 1, 1, 1);
  return beginningNextMonth.subtract(new Duration(days: 1));
}

DateTime getLastDayOfYear(int year) {
  var date = new DateTime(year, DateTime.december);
  var beginningNextMonth = (date.month < 12)
      ? new DateTime(date.year, date.month + 1, 1)
      : new DateTime(date.year + 1, 1, 1);
  return beginningNextMonth.subtract(new Duration(days: 1));
}
