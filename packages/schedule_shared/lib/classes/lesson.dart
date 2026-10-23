import 'package:json_annotation/json_annotation.dart';

import 'mark.dart';

part 'lesson.g.dart';

enum const AbsenceReason(this.id, this.title) {
  @JsonValue(null)
  none(null, ''),
  @JsonValue(1)
  sick(1, 'Б'),
  @JsonValue(2)
  absent(2, 'Н');

  final int? id;
  final String title;

  factory AbsenceReason.fromValue(int? value) => switch (value) {
    null => none,
    1 => sick,
    2 => absent,
    _ => throw ArgumentError('Unknown value: $value'),
  };

  int? toJson() => id;
}

@JsonSerializable(fieldRename: .snake)
class Lesson({
  final int? id,
  @JsonKey(name: 'subject_name') required final String name,
  @JsonKey(name: 'room_number') required final String room,
  final List<Mark> marks = const [],
  @JsonKey(name: 'absence_reason_id') final AbsenceReason absenceReason = .none,
  required final DateTime startAt,
  required final DateTime finishAt,
}) {
  this : assert(startAt.isBefore(finishAt));

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
  Map<String, dynamic> toJson() => _$LessonToJson(this);

  bool isCurrentAt(DateTime now, {Duration offset = Duration.zero}) =>
      !now.isBefore(startAt.add(offset)) && now.isBefore(finishAt.add(offset));

  bool get isCurrent => isCurrentAt(DateTime.now());

  Lesson copyWith({
    int? id,
    String? name,
    String? room,
    List<Mark>? marks,
    AbsenceReason? absenceReason,
    DateTime? startAt,
    DateTime? finishAt,
  }) => Lesson(
    id: id ?? this.id,
    name: name ?? this.name,
    room: room ?? this.room,
    marks: marks ?? this.marks,
    absenceReason: absenceReason ?? this.absenceReason,
    startAt: startAt ?? this.startAt,
    finishAt: finishAt ?? this.finishAt,
  );
}
