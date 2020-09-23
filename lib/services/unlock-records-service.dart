import 'dart:core';

import 'package:collection/collection.dart';
import 'package:rHabbit/models/unlock-record.dart';
import 'package:rHabbit/utils/date-time-utils.dart';

class UnlockRecordsService {
  List<UnlockRecord> _records;

  UnlockRecordsService();

  setData(List<UnlockRecord> records) {
    this._records = records;
  }

  Map<int, List<UnlockRecord>> groupByDay(DateTime day) {
    var groupedByDay = groupBy(
        _records, (UnlockRecord obj) => getStringFromDate(obj.timestamp));
    var formattedDay = formatADate(day, 'yyyy-MM-dd');

    if (groupedByDay.containsKey(formattedDay)) {
      return groupBy(
          groupedByDay[formattedDay], (UnlockRecord obj) => obj.timestamp.hour);
    }
    return Map<int, List<UnlockRecord>>();
  }

  Map<String, List<UnlockRecord>> groupByWeek(int numberOfWeek) {
    var groupedRecords =
        groupBy(_records, (UnlockRecord obj) => getWeekNumber(obj.timestamp));
    if (groupedRecords.containsKey(numberOfWeek)) {
      return groupBy(groupedRecords[numberOfWeek],
          (UnlockRecord obj) => getStringFromDate(obj.timestamp));
    }
    return Map<String, List<UnlockRecord>>();
  }

  Map<int, List<UnlockRecord>> groupByYear(int year) {
    var groupedRecords =
        groupBy(_records, (UnlockRecord obj) => (obj.timestamp.year));

    if (groupedRecords.containsKey(year)) {
      return groupBy(
          groupedRecords[year], (UnlockRecord obj) => obj.timestamp.month);
    }
    return Map<int, List<UnlockRecord>>();
  }

  Map<String, List<UnlockRecord>> groupByMonth(int month, int year) {
    var groupedByYear = this.groupByYear(year);

    if (groupedByYear.containsKey(month)) {
      return groupBy(groupedByYear[month],
          (UnlockRecord obj) => getStringFromDate(obj.timestamp));
    }
    return Map<String, List<UnlockRecord>>();
  }

  int getTodayCount(DateTime date) {
    var records = groupBy(
        _records, (UnlockRecord obj) => getStringFromDate(obj.timestamp));
    var today = formatADate(date, 'yyyy-MM-dd');
    if (records.containsKey(today)) {
      return records[today].length;
    }
    return 0;
  }

  int getWeekCount(weekNumber) {
    var groupedRecords =
        groupBy(_records, (UnlockRecord obj) => getWeekNumber(obj.timestamp));
    if (groupedRecords.containsKey(weekNumber)) {
      return groupedRecords[weekNumber].length;
    }
    return 0;
  }

  int getMonthCount(int month, int year) {
    var groupedByYear = this.groupByYear(year);
    if (groupedByYear.containsKey(month)) {
      return groupedByYear[month].length;
    }
    return 0;
  }

  int getYearCount(int year) {
    var records = this.groupByYear(year);
    if (records.containsKey(year)) {
      return records[year].length;
    }
    return 0;
  }

  bool isThereMoreRecordsBefore(DateTime date) {
    return this._records.any((r) => r.timestamp.isBefore(date));
  }

  bool isThereMoreRecordsAfter(DateTime date) {
    return this._records.any((r) => r.timestamp.isAfter(date));
  }
}
