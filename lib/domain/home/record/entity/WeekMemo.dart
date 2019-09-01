
import 'package:todo_app/Utils.dart';

class WeekMemo {

  static String dateTimeToDateString(DateTime dateTime) {
    final weeklySeparatedMonthAndNthWeek = Utils.getWeeklySeparatedMonthAndNthWeek(dateTime);
    return '${dateTime.year}-${weeklySeparatedMonthAndNthWeek.item1}-${weeklySeparatedMonthAndNthWeek.item2}';
  }

  final DateTime dateTime;
  final int index;
  final String content;

  String get key => '${dateTimeToDateString(dateTime)}-$index';

  const WeekMemo(this.dateTime, this.index, {
    this.content = '',
  });

  WeekMemo getModified({
    DateTime dateTime,
    int index,
    String content,
  }) {
    return WeekMemo(
      dateTime ?? this.dateTime,
      index ?? this.index,
      content: content ?? this.content,
    );
  }

  Map<String, dynamic> toDatabaseFormat() {
    return {
      'date_string': dateTimeToDateString(dateTime),
      'which': index,
      'content': content,
    };
  }

}