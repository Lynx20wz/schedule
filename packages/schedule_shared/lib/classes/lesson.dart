import 'marks.dart';

enum AbsenceReason {
  none(null, ''),
  sick(1, 'Б'),
  absent(2, 'Н');

  final int? id;
  final String title;

  const AbsenceReason(this.id, this.title);

  factory AbsenceReason.fromValue(int? value) => switch (value) {
    null => none,
    1 => sick,
    2 => absent,
    _ => throw ArgumentError('Unknown value: $value'),
  };
}

class Lesson {
  final String name;
  final String room;
  final List<Marks> marks;
  final AbsenceReason absenceReason;
  final DateTime startAt;
  final DateTime finishAt;

  Lesson({
    required this.name,
    required this.room,
    required this.marks,
    required this.absenceReason,
    required this.startAt,
    required this.finishAt,
  });

  factory Lesson.fromMap(Map<String, dynamic> map) {
    String subjectName = map['subject_name'];
    return Lesson(
      name: subjectName,
      room: map['room_number'],
      marks: List<Marks>.from(
        map['marks']?.map((markMap) => Marks.fromMap(subjectName, markMap)) ??
            [],
      ),
      absenceReason: AbsenceReason.fromValue(map['absence_reason_id']),
      startAt: DateTime.parse(map['start_at']),
      finishAt: DateTime.parse(map['finish_at']),
    );
  }
}
