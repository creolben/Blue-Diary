
import 'package:todo_app/domain/home/record/entity/DayRecord.dart';
import 'package:todo_app/domain/home/record/entity/WeekMemoSet.dart';
import 'package:tuple/tuple.dart';

class RecordState {
  final int year;
  final Tuple2<int, int> weeklySeparatedMonthAndNthWeek;
  final WeekMemoSet weekMemoSet;
  final List<DayRecord> dayRecords;

  const RecordState({
    this.year = 0,
    this.weeklySeparatedMonthAndNthWeek = const Tuple2(0, 0),
    this.weekMemoSet = const WeekMemoSet(),
    this.dayRecords = const [],
  });

  String get yearText => '$year년';

  String get monthAndNthWeekText {
    final month = weeklySeparatedMonthAndNthWeek.item1;
    final nthWeek = weeklySeparatedMonthAndNthWeek.item2;
    switch (nthWeek) {
      case 0:
        return '$month월 첫째주';
      case 1:
        return '$month월 둘째주';
      case 2:
        return '$month월 셋째주';
      case 3:
        return '$month월 넷째주';
      case 4:
        return '$month월 다섯째주';
      default:
        throw Exception('invalid nthWeek value: $nthWeek');
    }
  }

  RecordState getModified({
    int year,
    Tuple2<int, int> weeklySeparatedMonthAndNthWeek,
    WeekMemoSet weekMemoSet,
    List<DayRecord> days,
  }) {
    return RecordState(
      year: year ?? this.year,
      weeklySeparatedMonthAndNthWeek: weeklySeparatedMonthAndNthWeek ?? this.weeklySeparatedMonthAndNthWeek,
      weekMemoSet: weekMemoSet ?? this.weekMemoSet,
      dayRecords: days ?? this.dayRecords,
    );
  }

}