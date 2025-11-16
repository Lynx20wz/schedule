import 'package:flutter/material.dart';
import 'package:wear_os_plugin/wear_os_clipper.dart';

import '../classes/lesson.dart';

class LessonWidget extends StatelessWidget {
  final Lesson lesson;

  const LessonWidget(this.lesson, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WearOsClipper(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.secondaryContainer,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                lesson.room.toString(),
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.headlineSmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
