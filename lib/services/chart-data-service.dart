import 'package:rHabbit/models/chart-type.dart';
import 'package:rHabbit/models/phone-unlocks.dart';
import 'package:rHabbit/models/rhabbit-state.dart';
import 'package:rHabbit/models/unlock-record.dart';
import 'package:rHabbit/services/unlock-records-service.dart';
import 'package:rHabbit/utils/date-time-utils.dart';

class ChartDataService {
  UnlockRecordsService _service;
  RhabbitState _state;

  void setService(UnlockRecordsService service) {
    this._service = service;
  }

  List<PhoneUnlocks> buildChartData(ChartType chartType, RhabbitState state) {
    this._state = state;
    switch (chartType) {
      case ChartType.day:
        return _buildTodaySeries();
        break;
      case ChartType.week:
        return _buildWeekSeries();
        break;
      case ChartType.month:
        return _buildMonthSeries();
      case ChartType.year:
        return _buildYearSeries();
      default:
        return List<PhoneUnlocks>();
    }
  }

  List<PhoneUnlocks> _buildYearSeries() {
    List<PhoneUnlocks> data = new List<PhoneUnlocks>();
    var thisYearRecords = _service.groupByYear(DateTime.now().year);

    for (var i = 1; i <= DateTime.monthsPerYear; i++) {
      if (thisYearRecords.containsKey(i)) {
        data.add(new PhoneUnlocks(
            new DateTime(DateTime.now().year, i), thisYearRecords[i].length));
      }
    }
    _addEmtyRecordsIfNeeded(data);
    return data;
  }

  void _addEmtyRecordsIfNeeded(List<PhoneUnlocks> data) {
    if (data.length == 1) {
      var date = data.first.timestamp;
      if (date.month != DateTime.december) {
        data.add(new PhoneUnlocks(new DateTime(date.year, date.month + 1), 0));
      }
      if (date.month != DateTime.january)
        data.add(new PhoneUnlocks(new DateTime(date.year, date.month - 1), 0));
    }
  }

  List<PhoneUnlocks> _buildMonthSeries() {
    List<PhoneUnlocks> data = new List<PhoneUnlocks>();
    var monthRecords =
        _service.groupByMonth(DateTime.now().month, DateTime.now().year);
    var lastDayOfTheMonth = lastDayOfMonth(DateTime.now()).day;
    for (var i = 0; i < lastDayOfTheMonth; i++) {
      int counts = 0;
      if (monthRecords.length - i <= 0) {
        continue;
      }

      counts = monthRecords[monthRecords.keys.elementAt(i)].length;
      data.add(new PhoneUnlocks(
          DateTime.parse(monthRecords.keys.elementAt(i)), counts));
    }
    return data;
  }

  List<PhoneUnlocks> _buildWeekSeries() {
    var data = new List<PhoneUnlocks>();
    var weekRecords = _service.groupByWeek(_state.getWeek());
    for (int i = 0; i < DateTime.daysPerWeek; i++) {
      if (_shouldAddEmptyDay(weekRecords, data, i)) {
        _addEmptyDayRecordOnNextDay(data);
        continue;
      }
      _addDayRecord(weekRecords, data, i);
    }
    return data;
  }

  bool _shouldAddEmptyDay(Map<String, List<UnlockRecord>> weekRecords,
      List<PhoneUnlocks> data, int i) {
    bool noMoreRecordsToIterate = weekRecords.length - i <= 0;
    return noMoreRecordsToIterate && data.length != 0;
  }

  void _addEmptyDayRecordOnNextDay(List<PhoneUnlocks> data) {
    var nextDay = data.last.timestamp.add(new Duration(days: 1));
    data.add(new PhoneUnlocks(nextDay, 0));
  }

  void _addDayRecord(Map<String, List<UnlockRecord>> weekRecords,
      List<PhoneUnlocks> data, int i) {
    var counts = weekRecords[weekRecords.keys.elementAt(i)].length;
    data.add(new PhoneUnlocks(
        DateTime.parse(weekRecords.keys.elementAt(i)), counts));
  }

  List<PhoneUnlocks> _buildTodaySeries() {
    List<PhoneUnlocks> data = new List<PhoneUnlocks>();
    var todayRecords = _service.groupByDay(_state.getDate());
    for (var key in todayRecords.keys) {
      var date = new DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, key);
      data.add(new PhoneUnlocks(date, todayRecords[key].length));
    }

    if (data.length <= 2) {
      var lastRecord = data.last.timestamp;
      if (lastRecord.hour < 24) {
        var nextHour = new DateTime(lastRecord.year, lastRecord.month,
            lastRecord.day, lastRecord.hour + 1);
        data.add(new PhoneUnlocks(nextHour, 0));
      }
    }
    return data;
  }
}
