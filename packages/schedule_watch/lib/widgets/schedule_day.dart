import 'package:flutter/material.dart';
import 'package:schedule_shared/schedule_shared.dart';
import 'package:schedule_watch/screens/empty.dart';

import 'lesson.dart';

class ScheduleDayWidget extends StatefulWidget {
  final Weekday nameDay;
  final List<Lesson> lessonsForDay;
  final Duration offset;

  const ScheduleDayWidget(
    this.nameDay,
    this.lessonsForDay, {
    super.key,
    this.offset = Duration.zero,
  });

  @override
  State<ScheduleDayWidget> createState() => _ScheduleDayWidgetState();
}

class _ScheduleDayWidgetState extends State<ScheduleDayWidget> {
  final _scrollController = ScrollController();
  final _currentLessonKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToCurrentLesson();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentLesson() {
    final lessonContext = _currentLessonKey.currentContext;
    if (lessonContext == null) return;

    final renderObject = lessonContext.findRenderObject();
    if (renderObject == null) return;

    final scrollable = Scrollable.maybeOf(lessonContext, axis: Axis.vertical);
    scrollable?.position.ensureVisible(renderObject, alignment: 0.1);
  }

  @override
  Widget build(BuildContext context) => widget.lessonsForDay.isEmpty
      ? const EmptyScreen('No lessons today')
      : Column(
          children: [
            Text(
              widget.nameDay.capitalizedTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 35),
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemCount: widget.lessonsForDay.length,
                  itemBuilder: (_, index) {
                    final lesson = widget.lessonsForDay[index];

                    return LessonWidget(
                      lesson,
                      offset: widget.offset,
                      key:
                          lesson.isCurrentAt(
                            DateTime.now(),
                            offset: widget.offset,
                          )
                          ? _currentLessonKey
                          : null,
                    );
                  },
                ),
              ),
            ),
          ],
        );
}
