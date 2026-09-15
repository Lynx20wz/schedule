import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

class WatchWidget extends StatelessWidget {
  const WatchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final is24Format = MediaQuery.of(context).alwaysUse24HourFormat;
    return Center(
      child: Text(
        DateFormat('${is24Format ? 'HH' : 'hh'}:mm').format(DateTime.now()),
        style: const TextStyle(fontWeight: .bold, fontSize: 16),
      ),
    );
  }
}
