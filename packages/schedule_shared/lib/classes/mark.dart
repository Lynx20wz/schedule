import 'package:json_annotation/json_annotation.dart';

part 'mark.g.dart';

@JsonSerializable(fieldRename: .snake)
class Mark(
  final String value, {
  final int? id,
  final String? comment,
  final int weight = 1,
  final bool isExam = false,
  final bool isPoint = false,
}) {
  factory Mark.fromJson(Map<String, dynamic> json) => _$MarkFromJson(json);
  Map<String, dynamic> toJson() => _$MarkToJson(this);
}

@JsonSerializable(fieldRename: .snake)
class DetailedMark(
  super.value, {
  super.id,
  super.comment,
  super.weight,
  super.isExam,
  super.isPoint,
  required final DateTime date,
  required final String subjectName,
  required final String controlFormName,
  required final DateTime createdAt,
  required final DateTime updatedAt,
}) extends Mark {
  factory DetailedMark.fromJson(Map<String, dynamic> json) =>
      _$DetailedMarkFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DetailedMarkToJson(this);
}
