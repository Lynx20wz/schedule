import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_devtools/riverpod_devtools.dart'
    show RiverpodDevToolsObserver;
import 'package:schedule_phone/screens/screens.dart';

void main() => runApp(
  ProviderScope(
    observers: [RiverpodDevToolsObserver()],
    child: MaterialApp(
      title: 'Schedule',
      theme: .from(
        colorScheme: .fromSeed(seedColor: Colors.blue, brightness: .dark),
      ),
      home: const HomeScreen(),
    ),
  ),
);
