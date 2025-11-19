import 'package:flutter/material.dart';

import '../widgets/widgets.dart';

class EmptyScreen extends StatelessWidget {
  final String msg;

  const EmptyScreen(this.msg, {super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const WatchWidget(),
      Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              msg,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ],
  );
}
