import 'lesson.dart';

enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  static Weekday fromIndex(int index) => values[index - 1];
}

class Schedule {
  final int totalCount;
  final List<Lesson> lessons;

  Schedule({required this.totalCount, required this.lessons});

  factory Schedule.fromMap(Map<String, dynamic> map) => Schedule(
    totalCount: map['total_count'] ?? 0,
    lessons: List<Lesson>.from(
      map['response']?.map((item) => Lesson.fromMap(item)) ?? [],
    ),
  );

  Map<String, List<Lesson>> get days {
    final Map<String, List<Lesson>> result = {
      for (var weekday in Weekday.values) weekday.name: [],
    };

    for (var lesson in lessons) {
      String weekday = Weekday.fromIndex(lesson.startAt.weekday).name;
      result[weekday]!.add(lesson);
    }

    return result;
  }
}
