import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schedule_shared/exceptions.dart';
import 'package:schedule_shared/schedule_shared.dart';
import 'package:schedule_watch/providers/providers.dart';
import 'package:schedule_watch/screens/screens.dart';
import 'package:schedule_watch/widgets/widgets.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  final PageController _pageController = PageController(
    initialPage: DateTime.now().weekday - 1,
    keepPage: false,
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offset = ref.watch(lessonOffsetProvider);

    return Scaffold(
      body: ref
          .watch(scheduleProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) {
              if (e is TokenException) return const TokenScreen();
              log(e.toString(), stackTrace: st);
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      Text(e.toString(), textAlign: .center),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: () => ref.invalidate(scheduleProvider),
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              );
            },
            data: (schedule) => Column(
              children: [
                const Center(child: WatchWidget()),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: schedule.lessonsByDays.length,
                    itemBuilder: (context, index) {
                      final entry = schedule.lessonsByDays.entries
                          .toList()[index];
                      return OneDaySchedule(
                        entry.key,
                        entry.value,
                        offset: offset,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class OneDaySchedule extends StatefulWidget {
  final Weekday nameDay;
  final List<Lesson> lessonsForDay;
  final Duration offset;

  const OneDaySchedule(
    this.nameDay,
    this.lessonsForDay, {
    super.key,
    this.offset = Duration.zero,
  });

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
