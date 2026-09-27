import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

class WatchWidget extends StatefulWidget {
  const WatchWidget({super.key});
  @override
  State<WatchWidget> createState() => _WatchWidgetState();
}

class _WatchWidgetState extends State<WatchWidget> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final is24 = MediaQuery.of(context).alwaysUse24HourFormat;
    return Center(
      child: Text(
        DateFormat('${is24 ? 'HH' : 'hh'}:mm').format(DateTime.now()),
        style: const TextStyle(fontWeight: .bold, fontSize: 16),
      ),
    );
  }
}
