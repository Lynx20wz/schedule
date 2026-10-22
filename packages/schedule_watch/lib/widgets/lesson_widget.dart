import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:schedule_shared/schedule_shared.dart' show Lesson;

class LessonWidget extends StatefulWidget {
  final Lesson lesson;
  final Duration offset;
  // For mock
  final DateTime Function() now;

  const LessonWidget(
    this.lesson, {
    super.key,
    this.offset = Duration.zero,
    this.now = DateTime.now,
  });

  @override
  State<LessonWidget> createState() => _LessonWidgetState();
}

class _LessonWidgetState extends State<LessonWidget> {
  Timer? _timer;

  void _scheduleUpdate() {
    _timer?.cancel();

    final now = widget.now();
    final lesson = widget.lesson;
    final startAt = lesson.startAt.add(widget.offset);
    final finishAt = lesson.finishAt.add(widget.offset);

    Duration? delay;

    // Calculate the next update delay. Add a small offset so the widget is
    // rebuilt after the boundary, not exactly at it.
    if (now.isBefore(startAt)) {
      delay = startAt.difference(now);
    } else if (now.isBefore(finishAt)) {
      delay = finishAt.difference(now);
    }

    if (delay != null) {
      _timer = Timer(delay + const Duration(seconds: 1), () {
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
  void didUpdateWidget(LessonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.lesson != widget.lesson ||
        oldWidget.offset != widget.offset) {
      _scheduleUpdate();
    }
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
      color: widget.lesson.isCurrentAt(widget.now(), offset: widget.offset)
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
