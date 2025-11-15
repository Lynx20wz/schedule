import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
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
  Widget build(BuildContext context) => Scaffold(
    body: WatchShape(
      builder: (context, watchShape, _) => Padding(
        padding: const EdgeInsets.only(right: 40, left: 40),
        child: FutureBuilder(
          future: getSchedule(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(child: CircularProgressIndicator());
            }

            final schedule = Schedule.fromJson(snapshot.data!);
            final lessons = schedule.days[currentWeekday] ?? [];

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
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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

class WatchWidget extends StatelessWidget {
  const WatchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        DateFormat('HH:mm').format(DateTime.now()),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
