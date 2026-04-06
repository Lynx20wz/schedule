import 'marks.dart';

class Lesson {
  final String name;
  final String room;
  final List<Marks> marks;
  final DateTime startAt;
  final DateTime finishAt;

  Lesson({
    required this.name,
    required this.room,
    required this.marks,
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
      startAt: DateTime.parse(map['start_at']),
      finishAt: DateTime.parse(map['finish_at']),
    );
  }
}
