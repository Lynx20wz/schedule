import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

class WatchWidget extends StatelessWidget {
  const WatchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isFullFormat = MediaQuery.of(context).alwaysUse24HourFormat;
    return Center(
      child: Text(
        DateFormat('${isFullFormat ? 'HH' : 'hh'}:mm').format(DateTime.now()),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
