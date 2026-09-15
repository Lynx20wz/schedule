import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            log(e.toString(), stackTrace: st);
            return Center(child: Text(e.toString()));
          },
          // null only if token is invalid
          data: (schedule) => schedule == null
              ? TokenScreen()
              : Column(
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

class OneDaySchedule extends StatelessWidget {
  final Weekday nameDay;
  final List<Lesson> lessonsForDay;

  const OneDaySchedule(this.nameDay, this.lessonsForDay, {super.key});

  @override
  Widget build(BuildContext context) => lessonsForDay.isEmpty
      ? const EmptyScreen('No lessons today')
      : Column(
          children: [
            Text(
              nameDay.getCapitalizedName(),
              style: const TextStyle(fontWeight: .bold, fontSize: 16),
            ),
            Expanded(
              child: Padding(
                padding: const .symmetric(horizontal: 30),
                child: ListView.separated(
                  padding: .only(bottom: 35),
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemCount: lessonsForDay.length,
                  itemBuilder: (_, index) => LessonWidget(lessonsForDay[index]),
                ),
              ),
            ),
          ],
        );
}
