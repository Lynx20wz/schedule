import 'package:flutter/material.dart';
import 'package:wear_plus/wear_plus.dart';

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

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: WatchShape(
          builder: (context, shape, child) => Text(shape.name),
          // child:
        ),
      ),
    );
  }
}
