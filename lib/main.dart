import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wear_plus/wear_plus.dart';

import 'api.dart';
import 'schemas.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const StartPage(),
      theme: ThemeData.dark(useMaterial3: true),
    );
  }
}

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final String currentWeekday = Weekday.fromIndex(DateTime.now().weekday).name;
  Schedule? schedule;

  @override
  void initState() {
    super.initState();
    _getSchedule();
  }

  void _getSchedule() async {
    schedule = Schedule.fromJson(await getSchedule());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: WatchShape(
        builder: (context, watchShape, _) => Container(
          // decoration: BoxDecoration(
          //   shape: watchShape == WearShape.round
          //       ? BoxShape.circle
          //       : BoxShape.rectangle,
          // ),
          padding: const EdgeInsets.only(top: 8, right: 40, left: 40),
          child: Column(
            children: [
              Text(
                DateFormat('HH:mm').format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: schedule?.days[currentWeekday]?.length ?? 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final lessons = schedule?.days[currentWeekday];
                    return lessons == null
                        ? const CircularProgressIndicator()
                        : LessonWidget(lessons[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class LessonWidget extends StatelessWidget {
  final Lesson lesson;

  const LessonWidget(this.lesson, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.secondaryContainer,
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
    );
  }
}
