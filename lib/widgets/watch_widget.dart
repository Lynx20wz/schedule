import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

class WatchWidget extends StatelessWidget {
  const WatchWidget({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      DateFormat('HH:mm').format(DateTime.now()),
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
  );
}
