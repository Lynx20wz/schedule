import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_devtools/riverpod_devtools.dart'
    show RiverpodDevToolsObserver;
import 'package:schedule_phone/auth_flow.dart';
import 'package:schedule_phone/screens/screens.dart';

void main() => runApp(
  ProviderScope(
    observers: [RiverpodDevToolsObserver()],
    child: const ScheduleApp(),
  ),
);

class ScheduleApp extends ConsumerWidget {
  const ScheduleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep the deeplink listener alive for the whole app session.
    ref.watch(authFlowProvider);

    return MaterialApp(
      title: 'Schedule',
      theme: .from(
        colorScheme: .fromSeed(seedColor: Colors.blue, brightness: .dark),
      ),
      home: const HomeScreen(),
    );
  }
}
