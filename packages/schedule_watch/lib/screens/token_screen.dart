import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schedule_shared/providers/providers.dart' show tokenProvider;
import 'package:schedule_watch/screens/screens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

class TokenScreen extends ConsumerStatefulWidget {
  const TokenScreen({super.key});

  @override
  ConsumerState<TokenScreen> createState() => _TokenScreenState();
}

class _TokenScreenState extends ConsumerState<TokenScreen> {
  final _watchConnectivity = WatchConnectivity();

  @override
  void initState() {
    super.initState();
    initToken();
  }

  void initToken() async {
    // String? token = await _loadToken();
    // if (token != null) return;

    final receivedContext =
        (await _watchConnectivity.receivedApplicationContexts)[0];

    log(receivedContext.toString(), name: '_TokenScreenState.initToken');

    if (receivedContext case {'token': final String token}) {
      await _saveToken(token);
      return;
    }

    _watchConnectivity.contextStream.listen((context) {
      log(context.toString(), name: '_TokenScreenState.initToken');
      if (context case {'token': final token}) _saveToken(token);
    });
  }

  Future<void> _saveToken(String token) async {
    ref.read(tokenProvider.notifier).setToken(token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  Widget build(BuildContext context) => EmptyScreen('Please provide a token');
}
