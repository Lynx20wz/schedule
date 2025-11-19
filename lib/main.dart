import 'package:flutter/material.dart';
import 'package:wear_os_plugin/wear_os_app.dart';

import 'screens/screens.dart' show ScheduleScreen;

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return WearOsApp(
      screenBuilder: (_) => ScheduleScreen(),
      theme: ThemeData.dark(useMaterial3: true),
    );
  }
}
