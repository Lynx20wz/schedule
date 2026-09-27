import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:schedule_shared/schedule_shared.dart' show Lesson;

class LessonWidget extends StatefulWidget {
  final Lesson lesson;

  const LessonWidget(this.lesson, {super.key});

  @override
  State<LessonWidget> createState() => _LessonWidgetState();
}

class _LessonWidgetState extends State<LessonWidget> {
  Timer? _timer;

  void _scheduleUpdate() {
    final now = DateTime.now();
    final lesson = widget.lesson;
    Duration? delay;

    // Calculate the next update delay
    if (now.isBefore(lesson.startAt)) {
      delay = lesson.startAt.difference(now);
    } else if (now.isBefore(lesson.finishAt)) {
      delay = lesson.finishAt.difference(now);
    }

    if (delay != null && delay > Duration.zero) {
      _timer = Timer(delay, () {
        if (mounted) {
          setState(() {});
          _scheduleUpdate();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scheduleUpdate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: .circular(8),
      color: widget.lesson.isCurrent
          ? Colors.indigo.shade300
          : Theme.of(context).colorScheme.secondaryContainer,
    ),
    child: ListTile(
      title: Text(widget.lesson.name, overflow: .ellipsis),
      subtitle: Text(widget.lesson.room),
      contentPadding: const .symmetric(horizontal: 8),
      trailing: Text(
        widget.lesson.marks.isNotEmpty
            ? widget.lesson.marks.map((m) => m.value).join('|')
            : widget.lesson.absenceReason.title,
        style: const TextStyle(fontWeight: .bold, fontSize: 16),
      ),
    ),
  );
}
