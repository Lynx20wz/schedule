import 'package:flutter/material.dart';
import 'package:wear_os_plugin/wear_os_clipper.dart';

import '../widgets/watch_widget.dart';

class MarksScreen extends StatelessWidget {
  const MarksScreen({super.key});

  @override
  Widget build(BuildContext context) => WearOsClipper(
    child: Scaffold(
      body: Column(
        children: [
          WatchWidget(),
          const Expanded(
            child: Center(
              child: Text(
                'Marks Screen',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
