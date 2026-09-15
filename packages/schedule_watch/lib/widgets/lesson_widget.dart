import 'package:flutter/material.dart';
import 'package:schedule_shared/schedule_shared.dart' show Lesson;

class LessonWidget extends StatelessWidget {
  final Lesson lesson;

  const LessonWidget(this.lesson, {super.key});

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontWeight: .bold, fontSize: 16);

    return Container(
      decoration: BoxDecoration(
        borderRadius: .circular(8),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: ListTile(
        title: Text(lesson.name, overflow: .ellipsis),
        subtitle: Text(lesson.room),
        contentPadding: const .symmetric(horizontal: 8),
        trailing: lesson.marks.isNotEmpty
            ? Text(lesson.marks[0].mark.toString(), style: textStyle)
            : Text(lesson.absenceReason.title, style: textStyle),
      ),
    );
  }
}
