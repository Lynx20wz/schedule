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

  late Schedule? schedule;

  @override
  Widget build(BuildContext context) => WearOsClipper(
    child: Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(right: 40, left: 40),
        child: FutureBuilder(
          future: parser.getSchedule(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(child: CircularProgressIndicator());
            }

            schedule = Schedule.fromMap(snapshot.data!);
            final lessons = schedule?.lessonsForToday ?? [];

            if (lessons.isEmpty) {
              return Column(
                children: [
                  WatchWidget(),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No lessons today',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.only(bottom: 30),
              itemCount: lessons.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) => index == 0
                  ? Center(child: WatchWidget())
                  : LessonWidget(lessons[index - 1]),
            );
          },
        ),
      ),
    ),
  );
}
