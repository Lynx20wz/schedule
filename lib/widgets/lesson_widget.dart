import 'package:flutter/material.dart';
import 'package:wear_os_plugin/wear_os_clipper.dart';

import '../classes/lesson.dart';

class LessonWidget extends StatelessWidget {
  final Lesson lesson;

  const LessonWidget(this.lesson, {super.key});

  @override
  Widget build(BuildContext context) => WearOsClipper(
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: ListTile(
        title: Text(lesson.name),
        subtitle: Text(lesson.room),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        trailing: lesson.marks.isNotEmpty
            ? Text(lesson.marks[0].mark.toString())
            : null,
      ),
    ),
  );
}
