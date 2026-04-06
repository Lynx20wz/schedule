import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

class TokenScreen extends StatefulWidget {
  const TokenScreen({super.key});
  @override
  State<TokenScreen> createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  final _watch = WatchConnectivity();

  String token = '';

  @override
  void initState() {
    super.initState();

    _watch.sendMessage({'request_token': ''});

    _watch.messageStream.listen((msg) {
      log('Received message: $msg');
      setState(() => token = msg['token']);
    });
  }

  @override
  Widget build(BuildContext context) => Center(child: Text(token));
}
