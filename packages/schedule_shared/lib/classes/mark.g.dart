// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mark.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mark _$MarkFromJson(Map<String, dynamic> json) => Mark(
  json['value'] as String,
  id: (json['id'] as num?)?.toInt(),
  comment: json['comment'] as String?,
  weight: (json['weight'] as num?)?.toInt() ?? 1,
  isExam: json['is_exam'] as bool? ?? false,
  isPoint: json['is_point'] as bool? ?? false,
);

Map<String, dynamic> _$MarkToJson(Mark instance) => <String, dynamic>{
  'value': instance.value,
  'id': instance.id,
  'comment': instance.comment,
  'weight': instance.weight,
  'is_exam': instance.isExam,
  'is_point': instance.isPoint,
};

DetailedMark _$DetailedMarkFromJson(Map<String, dynamic> json) => DetailedMark(
  json['value'] as String,
  id: (json['id'] as num?)?.toInt(),
  comment: json['comment'] as String?,
  weight: (json['weight'] as num?)?.toInt() ?? 1,
  isExam: json['is_exam'] as bool? ?? false,
  isPoint: json['is_point'] as bool? ?? false,
  date: DateTime.parse(json['date'] as String),
  subjectName: json['subject_name'] as String,
  controlFormName: json['control_form_name'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$DetailedMarkToJson(DetailedMark instance) =>
    <String, dynamic>{
      'value': instance.value,
      'id': instance.id,
      'comment': instance.comment,
      'weight': instance.weight,
      'is_exam': instance.isExam,
      'is_point': instance.isPoint,
      'date': instance.date.toIso8601String(),
      'subject_name': instance.subjectName,
      'control_form_name': instance.controlFormName,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
