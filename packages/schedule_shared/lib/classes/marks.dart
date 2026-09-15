class Marks {
  final String subjectName;
  final String mark;

  Marks(this.subjectName, this.mark);

  factory Marks.fromMap(String subjectName, Map<String, dynamic> map) =>
      Marks(subjectName, map['value']);
}
