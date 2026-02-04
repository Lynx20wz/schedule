import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wear_os_plugin/wear_os_app.dart';

import 'screens/companion.dart' show PhoneAuthScreen;
import 'screens/screens.dart' show ScheduleScreen;

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? MaterialApp(
            theme: ThemeData.dark(useMaterial3: true),
            home: const PhoneAuthScreen(),
          )
        : WearOsApp(
            theme: ThemeData.dark(useMaterial3: true),
            screenBuilder: (_) => const ScheduleScreen(),
          );
  }
}
