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

class Lesson {
  final String name;
  final String room;
  final DateTime startAt;
  final DateTime finishAt;

  Lesson({
    required this.name,
    required this.room,
    required this.startAt,
    required this.finishAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    name: json['subject_name'],
    room: json['room_number'],
    startAt: DateTime.parse(json['start_at']),
    finishAt: DateTime.parse(json['finish_at']),
  );
}

class Schedule {
  final int totalCount;
  final List<Lesson> lessons;

  Schedule({required this.totalCount, required this.lessons});

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    totalCount: json['total_count'] ?? 0,
    lessons: List<Lesson>.from(
      json['response']?.map((item) => Lesson.fromJson(item)) ?? [],
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
