import 'lesson.dart';

enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  /// Examples:
  /// 1 -> Weekday.monday
  /// 2 -> Weekday.tuesday
  static Weekday fromIndex(int index) => values[index - 1];
  String getCapitalizedName() => '${name[0].toUpperCase()}${name.substring(1)}';
}

class Schedule({
  required final int totalCount,
  required final List<Lesson> lessons,
}) {
  /// Returns `true` if the current day is Saturday or Sunday.
  bool get isTodayWeekend =>
      currentWeekday == Weekday.saturday || currentWeekday == Weekday.sunday;

  /// The weekday of the day the schedule is for.
  final Weekday currentWeekday = Weekday.fromIndex(DateTime.now().weekday);

  new fromMap(Map<String, dynamic> map)
    : this(
        totalCount: map['total_count'] ?? 0,
        lessons: List<Lesson>.from(
          map['response']?.map((item) => Lesson.fromMap(item)) ?? [],
        ),
      );

  Map<Weekday, List<Lesson>> get lessonsByDays {
    final Map<Weekday, List<Lesson>> result = {
      for (var weekday in Weekday.values) weekday: [],
    };

    for (var lesson in lessons) {
      Weekday weekday = Weekday.fromIndex(lesson.startAt.weekday);
      result[weekday]!.add(lesson);
    }

    result.removeWhere((k, v) => v.isEmpty);
    return result;
  }

  List<Lesson> get lessonsForToday =>
      (isTodayWeekend
          ? lessonsByDays[Weekday.friday]
          : lessonsByDays[currentWeekday]) ??
      [];
}
