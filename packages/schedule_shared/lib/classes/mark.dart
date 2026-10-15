class Mark(
  final int id,
  final String value,
  final String? comment,
  final int weight,
  final bool isExam,
  final bool isPoint,
) {
  factory Mark.fromMap(Map<String, dynamic> map) => Mark(
    map['id'] as int,
    map['value'] as String,
    map['comment'] as String?,
    map['weight'] as int,
    map['is_exam'] as bool,
    map['is_point'] as bool,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'value': value,
    'comment': comment,
    'weight': weight,
    'is_exam': isExam,
    'is_point': isPoint,
  };
}

class DetailedMark(
  super.id,
  super.value,
  super.comment,
  super.weight,
  super.isExam,
  super.isPoint,
  final DateTime date,
  final String subjectName,
  final String controlFormName,
  final DateTime createdAt,
  final DateTime updatedAt,
) extends Mark {
  factory DetailedMark.fromMap(Map<String, dynamic> map) => DetailedMark(
    map['id'] as int,
    map['value'] as String,
    map['comment'] as String?,
    map['weight'] as int,
    map['is_exam'] as bool,
    map['is_point'] as bool,
    DateTime.parse(map['date'] as String),
    map['subject_name'] as String,
    map['control_form_name'] as String,
    DateTime.parse(map['created_at'] as String),
    DateTime.parse(map['updated_at'] as String),
  );

  @override
  Map<String, dynamic> toMap() => {
    ...super.toMap(),
    'date': date.toIso8601String(),
    'subject_name': subjectName,
    'control_form_name': controlFormName,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
