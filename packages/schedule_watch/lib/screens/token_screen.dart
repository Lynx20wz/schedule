import 'dart:async' show StreamSubscription;
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schedule_shared/providers/providers.dart' show tokenProvider;
import 'package:schedule_watch/screens/screens.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

class TokenScreen extends ConsumerStatefulWidget {
  const TokenScreen({super.key});

  @override
  ConsumerState<TokenScreen> createState() => _TokenScreenState();
}

class _TokenScreenState extends ConsumerState<TokenScreen> {
  final _watchConnectivity = WatchConnectivity();
  StreamSubscription<Map<String, dynamic>>? _contextSubscription;

  @override
  void initState() {
    super.initState();
    _contextSubscription = _watchConnectivity.contextStream.listen(_onContext);
    _readInitialContext();
  }

  @override
  void dispose() {
    _contextSubscription?.cancel();
    super.dispose();
  }

  Future<void> _readInitialContext() async {
    try {
      final contexts = await _watchConnectivity.receivedApplicationContexts;
      log(
        contexts.toString(),
        name: '_TokenScreenState.receivedApplicationContexts',
      );

      if (contexts.isNotEmpty) _onContext(contexts.first);
    } catch (e, st) {
      log(
        'Failed to read application contexts: $e',
        name: '_TokenScreenState._readInitialContext',
        stackTrace: st,
        error: e,
      );
    }
  }

  void _onContext(Map<String, dynamic> context) {
    log(context.toString(), name: '_TokenScreenState._onContext');
    if (!mounted) return;

    if (context case {'token': final String token}
        when ref.read(tokenProvider) != token) {
      ref.read(tokenProvider.notifier).setToken(token);
    }
  }

  @override
  Widget build(BuildContext context) => EmptyScreen('Please provide a token');
}
