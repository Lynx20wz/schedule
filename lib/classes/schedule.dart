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

class Schedule {
  final int totalCount;
  final List<Lesson> lessons;
  late final bool _isTodayWeekend;
  final Weekday currentWeekday = Weekday.fromIndex(DateTime.now().weekday);

  Schedule({required this.totalCount, required this.lessons}) {
    _isTodayWeekend =
        currentWeekday == Weekday.saturday || currentWeekday == Weekday.sunday;
  }

  factory Schedule.fromMap(Map<String, dynamic> map) => Schedule(
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

    return result;
  }

  List<Lesson> get lessonsForToday {
    final todayLessons = lessonsByDays[currentWeekday] ?? [];
    if (todayLessons.isNotEmpty) {
      return todayLessons;
    } else if (_isTodayWeekend) {
      return lessonsByDays[Weekday.friday] ?? [];
    }

    return [];
  }
}
