import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schedule_shared/exceptions.dart';
import 'package:schedule_shared/schedule_shared.dart';
import 'package:schedule_watch/lesson_offset.dart';
import 'package:schedule_watch/widgets/widgets.dart';

import 'token.dart';

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
                      return ScheduleDayWidget(
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
