import 'package:flutter/material.dart';

import 'auth.dart';
import 'marks.dart';
import 'schedule.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _index,
      children: const [AuthScreen(), MarksScreen(), ScheduleScreen()],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (index) => setState(() => _index = index),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.login), label: 'Авторизация'),
        NavigationDestination(icon: Icon(Icons.grade), label: 'Оценки'),
        NavigationDestination(
          icon: Icon(Icons.calendar_today),
          label: 'Расписание',
        ),
      ],
    ),
  );
}
