import 'mark.dart';

enum const AbsenceReason(final int? id, final String title) {
  none(null, ''),
  sick(1, 'Б'),
  absent(2, 'Н');

  factory fromValue(int? value) => switch (value) {
    null => none,
    1 => sick,
    2 => absent,
    _ => throw ArgumentError('Unknown value: $value'),
  };
}

class Lesson({
  required final String name,
  required final String room,
  required final List<Mark> marks,
  required final AbsenceReason absenceReason,
  required final DateTime startAt,
  required final DateTime finishAt,
}) {
  bool get isCurrent =>
      DateTime.now().isAfter(startAt) && DateTime.now().isBefore(finishAt);

  Lesson copyWith({
    String? name,
    String? room,
    List<Mark>? marks,
    AbsenceReason? absenceReason,
    DateTime? startAt,
    DateTime? finishAt,
  }) => Lesson(
    name: name ?? this.name,
    room: room ?? this.room,
    marks: marks ?? this.marks,
    absenceReason: absenceReason ?? this.absenceReason,
    startAt: startAt ?? this.startAt,
    finishAt: finishAt ?? this.finishAt,
  );

  new fromMap(Map<String, dynamic> map)
    : this(
        name: map['subject_name'],
        room: map['room_number'],
        marks: List<Mark>.from(
          map['marks']?.map((markMap) => Mark.fromMap(markMap)) ?? [],
        ),
        absenceReason: AbsenceReason.fromValue(map['absence_reason_id']),
        startAt: DateTime.parse(map['start_at']),
        finishAt: DateTime.parse(map['finish_at']),
      );
}
