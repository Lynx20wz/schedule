// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lesson _$LessonFromJson(Map<String, dynamic> json) => Lesson(
  id: (json['id'] as num?)?.toInt(),
  name: json['subject_name'] as String,
  room: json['room_number'] as String,
  marks:
      (json['marks'] as List<dynamic>?)
          ?.map((e) => Mark.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  absenceReason:
      $enumDecodeNullable(_$AbsenceReasonEnumMap, json['absence_reason_id']) ??
      .none,
  startAt: DateTime.parse(json['start_at'] as String),
  finishAt: DateTime.parse(json['finish_at'] as String),
);

Map<String, dynamic> _$LessonToJson(Lesson instance) => <String, dynamic>{
  'id': instance.id,
  'subject_name': instance.name,
  'room_number': instance.room,
  'marks': instance.marks,
  'absence_reason_id': instance.absenceReason,
  'start_at': instance.startAt.toIso8601String(),
  'finish_at': instance.finishAt.toIso8601String(),
};

const _$AbsenceReasonEnumMap = {
  AbsenceReason.none: null,
  AbsenceReason.sick: 1,
  AbsenceReason.absent: 2,
};
