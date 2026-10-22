import 'dart:async' show StreamSubscription;
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schedule_shared/providers/providers.dart' show tokenProvider;
import 'package:schedule_watch/providers/providers.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

class WatchSync extends ConsumerStatefulWidget {
  final Widget child;

  const WatchSync({required this.child, super.key});

  @override
  ConsumerState<WatchSync> createState() => _WatchSyncState();
}

class _WatchSyncState extends ConsumerState<WatchSync> {
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
      if (contexts.isNotEmpty) _onContext(contexts.first);
    } catch (e, st) {
      log(
        'Failed to read application contexts: $e',
        name: 'WatchSync._readInitialContext',
        stackTrace: st,
        error: e,
      );
    }
  }

  void _onContext(Map<String, dynamic> context) {
    if (!mounted) return;

    if (context.containsKey('token')) {
      final token = context['token'];

      if (token is String && ref.read(tokenProvider) != token) {
        ref.read(tokenProvider.notifier).setToken(token);
      } else if (token == null) {
        ref.read(tokenProvider.notifier).setToken(null);
      }
    }

    final offset = context['lessonOffsetSeconds'];
    if (offset is num) {
      ref
          .read(lessonOffsetProvider.notifier)
          .set(Duration(seconds: offset.toInt()));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
