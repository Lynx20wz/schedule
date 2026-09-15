import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:riverpod_devtools/riverpod_devtools.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'screens/screens.dart' show ScheduleScreen;

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await calculateAndSaveNextLesson();
    return Future.value(true);
  });
}

void main() async {
  // await setupWorkmanager();

  runApp(
    ProviderScope(
      observers: [RiverpodDevToolsObserver()],
      child: MaterialApp(
        title: 'Schedule',
        theme: ThemeData.dark(useMaterial3: true),
        home: const ScheduleScreen(),
      ),
    ),
  );
}

Future<void> setupWorkmanager() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Workmanager().initialize(callbackDispatcher);

  await Workmanager().registerPeriodicTask(
    "unique_task_id",
    "updateLessonTask",
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.notRequired),
  );
}

Future<void> calculateAndSaveNextLesson() async {
  final prefs = await SharedPreferences.getInstance();

  String nextLesson = "Математика, 10:00";

  await prefs.setString('next_lesson', nextLesson);
}
