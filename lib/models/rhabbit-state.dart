import 'package:rHabbit/utils/date-time-utils.dart';

class RhabbitState {
  int _weekNumber;
  int _monthNumber;
  int _yearNumber;
  int _dayNumber;
  DateTime _currentDate;

  RhabbitState.now() {
    this._setDate(DateTime.now());
  }

  RhabbitState(DateTime date) {
    this._currentDate = date;
    this._weekNumber = getWeekNumber(date);
    this._monthNumber = date.month;
    this._yearNumber = date.year;
    this._dayNumber = date.day;
  }

  _setDate(DateTime date) {
    this._currentDate = date;
    this._weekNumber = getWeekNumber(date);
    this._monthNumber = date.month;
    this._yearNumber = date.year;
    this._dayNumber = date.day;
  }

  add(Duration duration) {
    var newDate = this._currentDate.add(duration);
    this._setDate(newDate);
  }

  subtract(Duration duration) {
    var newDate = this._currentDate.subtract(duration);
    this._setDate(newDate);
  }

  setWeek(int weekNumber) {
    var newDate = getDateByWeekNumber(
        weeknumber: weekNumber, year: this.getYear(), start: true);

    this._setDate(newDate);
  }

  setYear(int yearNumber) {
    var newDate = new DateTime(yearNumber, this._currentDate.month,
        this._currentDate.day, this._currentDate.hour);
    this._setDate(newDate);
  }

  addMonth() {
    var newDate;
    if (getMonth() == DateTime.december) {
      newDate = new DateTime(getYear() + 1, DateTime.january);
    } else {
      newDate = new DateTime(getYear(), getMonth() + 1);
    }
    this._setDate(newDate);
  }

  void subtractMonth() {
    var newDate;
    if (getMonth() == DateTime.january) {
      newDate = new DateTime(getYear() - 1, DateTime.december);
    } else {
      newDate = new DateTime(getYear(), getMonth() - 1);
    }
    this._setDate(newDate);
  }

  int getWeek() {
    return this._weekNumber;
  }

  DateTime getDate() {
    return this._currentDate;
  }

  int getMonth() {
    return this._monthNumber;
  }

  int getYear() {
    return this._yearNumber;
  }
}
