import 'package:flutter/material.dart';
import 'package:wear_os_plugin/wear_os_clipper.dart';

import '../api.dart';
import '../classes/classes.dart';
import '../widgets/widgets.dart';
import 'empty_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final Parser parser = Parser();

  @override
  Widget build(BuildContext context) => WearOsClipper(
    child: PopScope(
      canPop: false,
      child: Scaffold(
        body: FutureBuilder(
          future: parser.getSchedule(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const EmptyScreen('An exception occurred');
            }

            final schedule = Schedule.fromMap(snapshot.data!);

            if (schedule.lessons.isEmpty) {
              return const EmptyScreen('Schedule on week is empty');
            }

            return PageView.builder(
              controller: PageController(
                initialPage: DateTime.now().weekday - 1,
              ),
              itemCount: schedule.lessonsByDays.length,
              itemBuilder: (context, index) {
                final entry = schedule.lessonsByDays.entries.toList()[index];
                return OneDaySchedule(entry.key, entry.value);
              },
            );
          },
        ),
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
      : SingleChildScrollView(
          child: Column(
            children: [
              Center(child: WatchWidget()),
              Text(
                nameDay.getCapitalizedName(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                child: Column(
                  spacing: 4,
                  children: [
                    for (var lesson in lessonsForDay) LessonWidget(lesson),
                  ],
                ),
              ),
            ],
          ),
        );
}
