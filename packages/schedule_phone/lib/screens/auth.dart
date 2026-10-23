import 'dart:async';
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schedule_phone/auth_flow.dart';
import 'package:schedule_phone/lesson_offset.dart';
import 'package:schedule_phone/token_repo.dart';
import 'package:schedule_phone/widgets/lesson_offset_card.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

const minBtnSize = Size(double.infinity, 60);

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final WatchConnectivity _watchConnectivity = WatchConnectivity();
  final TextEditingController _tokenTextController = TextEditingController();
  Timer? _offsetSyncTimer;

  @override
  void dispose() {
    _tokenTextController.dispose();
    _offsetSyncTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendWatchContext() async {
    final offset = ref.read(lessonOffsetProvider).value ?? .zero;

    try {
      final tokens = await ref.read(tokensProvider.future);
      await _watchConnectivity.updateApplicationContext({
        'token': tokens?.access,
        'lessonOffsetSeconds': offset.inSeconds,
      });
    } catch (e, st) {
      log(
        'Failed to update watch context: $e',
        name: '_AuthScreenState._sendWatchContext',
        stackTrace: st,
        error: e,
      );
    }
  }

  Future<void> _setToken(Tokens tokens) async {
    await ref.read(tokensProvider.notifier).setTokens(tokens);
    _showSnackBar('Токен сохранен');
  }

  Future<void> _setTokenFromField() async {
    final text = _tokenTextController.text.trim();

    if (!Tokens.isValid(text)) {
      _showSnackBar(
        'Неверный токен (должно начинаться с eyJhb)',
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }

    await _setToken(Tokens(access: text, refresh: null));
  }

  Future<void> _clearToken() async =>
      await ref.read(tokensProvider.notifier).clear();

  void _openLoginUrl() async {
    try {
      await ref.read(authFlowProvider).login();
    } catch (e, st) {
      log(
        'Failed to open login URL: $e',
        name: '_AuthScreenState._openLoginUrl',
        stackTrace: st,
        error: e,
      );

      if (!mounted) return;
      _showSnackBar(
        'Не удалось открыть браузер',
        color: Theme.of(context).colorScheme.error,
      );
    }
  }

  void _showSnackBar(String message, {Color? color}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, textAlign: .center),
          duration: const Duration(seconds: 3),
          backgroundColor: color,
        ),
      );

  @override
  Widget build(BuildContext context) {
    ref.listen(lessonOffsetProvider, (_, next) {
      if (next.value == null) return;

      _offsetSyncTimer?.cancel();
      _offsetSyncTimer = Timer(const Duration(seconds: 1), _sendWatchContext);
    });

    ref.listen(tokensProvider, (_, next) {
      if (next.hasValue) unawaited(_sendWatchContext());
    });

    return ref
        .watch(tokensProvider)
        .when(
          error: (e, _) => Text('Error: $e'),
          loading: () => const CircularProgressIndicator(),
          data: (tokens) => Scaffold(
            appBar: AppBar(title: const Text('Авторизация часов')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                spacing: 16,
                children: tokens != null
                    ? _buildLogged(tokens.access)
                    : _buildNotLogged(),
              ),
            ),
          ),
        );
  }

  List<Widget> _buildLogged(String token) => [
    _buildTokenCard(token),
    const LessonOffsetCard(),
  ];

  List<Widget> _buildNotLogged() => [
    _buildLoginButton(),
    Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const .symmetric(horizontal: 16),
          child: Text('OR', style: TextStyle(fontSize: 14)),
        ),
        const Expanded(child: Divider()),
      ],
    ),
    _buildGetTokenButton(),
    TextField(
      controller: _tokenTextController,
      decoration: const InputDecoration(
        labelText: 'Токен авторизации',
        hintText: 'Введите токен начинающийся с eyJ...',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    ),
    ValueListenableBuilder(
      valueListenable: _tokenTextController,
      builder: (_, value, _) => ElevatedButton(
        onPressed: Tokens.isValid(value.text) ? _setTokenFromField : null,
        style: ElevatedButton.styleFrom(
          animationDuration: .zero,
          minimumSize: minBtnSize,
        ),
        child: const Text('Ввести токен'),
      ),
    ),
  ];

  Widget _buildLoginButton() => FilledButton.icon(
    icon: const Icon(Icons.login),
    label: const Text('Войти'),
    onPressed: _openLoginUrl,
    style: FilledButton.styleFrom(minimumSize: minBtnSize),
  );

  Widget _buildGetTokenButton() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return OutlinedButton.icon(
      icon: const Icon(Icons.key),
      label: const Text('Получите токен'),
      onPressed: null, // () async => await launchUrlString('https://authedu.mosreg.ru/50'),
      style: OutlinedButton.styleFrom(
        minimumSize: minBtnSize,
        foregroundColor: primaryColor,
        // side: BorderSide(width: 1.5, color: primaryColor),
      ),
    );
  }

  Widget _buildTokenCard(String token) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Токен сохранен: ${token.substring(0, 15)}...',
              style: const TextStyle(fontSize: 12),
              overflow: .ellipsis,
            ),
          ),
          Row(
            mainAxisSize: .min,
            children: [
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () async =>
                    Clipboard.setData(ClipboardData(text: token)),
                padding: EdgeInsets.zero,
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: _clearToken,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
