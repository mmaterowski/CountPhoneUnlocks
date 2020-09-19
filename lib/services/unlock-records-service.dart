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

  bool isThereMoreRecordsBefore(DateTime date) {
    return this._records.any((r) => r.timestamp.isBefore(date));
  }

  bool isThereMoreRecordsAfter(DateTime date) {
    return this._records.any((r) => r.timestamp.isAfter(date));
  }
}
