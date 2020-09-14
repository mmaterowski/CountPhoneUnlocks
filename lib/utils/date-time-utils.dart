import 'package:intl/intl.dart';

int weekNumber(DateTime date) {
  int dayOfYear = int.parse(DateFormat("D").format(date));
  return ((dayOfYear - date.weekday + 10) / 7).floor();
}

String getStringFromDate(DateTime dateTime) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(dateTime);
}

DateTime lastDayOfMonth(DateTime month) {
  var beginningNextMonth = (month.month < 12)
      ? new DateTime(month.year, month.month + 1, 1)
      : new DateTime(month.year + 1, 1, 1);
  return beginningNextMonth.subtract(new Duration(days: 1));
}
