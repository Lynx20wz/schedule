import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schedule_shared/exceptions.dart';
import 'package:schedule_shared/schedule_shared.dart';
import 'package:schedule_watch/screens/screens.dart';
import 'package:schedule_watch/widgets/widgets.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: ref
        .watch(scheduleProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) {
            if (e is TokenInvalidException) return TokenScreen();
            log(e.toString(), stackTrace: st);
            return Center(child: Text(e.toString()));
          },
          data: (schedule) => Column(
            children: [
              const Center(child: WatchWidget()),
              Expanded(
                child: PageView.builder(
                  controller: PageController(
                    initialPage: DateTime.now().weekday - 1,
                    keepPage: false,
                  ),
                  itemCount: schedule.lessonsByDays.length,
                  itemBuilder: (context, index) {
                    final entry = schedule.lessonsByDays.entries
                        .toList()[index];
                    return OneDaySchedule(entry.key, entry.value);
                  },
                ),
              ),
            ],
          ),
        ),
  );
}

class OneDaySchedule extends StatefulWidget {
  final Weekday nameDay;
  final List<Lesson> lessonsForDay;

  const OneDaySchedule(this.nameDay, this.lessonsForDay, {super.key});

  @override
  State<OneDaySchedule> createState() => _OneDayScheduleState();
}

class _OneDayScheduleState extends State<OneDaySchedule> {
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
    final context = _currentLessonKey.currentContext;
    if (context != null) Scrollable.ensureVisible(context, alignment: 0.1);
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
                      key: lesson.isCurrent ? _currentLessonKey : null,
                    );
                  },
                ),
              ),
            ),
          ],
        );
}
