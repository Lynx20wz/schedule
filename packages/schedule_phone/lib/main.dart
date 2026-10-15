import 'dart:async';
import 'dart:convert' show jsonDecode;
import 'dart:developer' show log;

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_devtools/riverpod_devtools.dart'
    show RiverpodDevToolsObserver;
import 'package:schedule_phone/api.dart';
import 'package:schedule_phone/token_repo.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/v4.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

const minBtnSize = Size(double.infinity, 60);

void main() => runApp(
  ProviderScope(
    observers: [RiverpodDevToolsObserver()],
    child: MaterialApp(
      title: 'Schedule',
      theme: .from(
        colorScheme: .fromSeed(seedColor: Colors.blue, brightness: .dark),
      ),
      home: const PhoneAuthScreen(),
    ),
  ),
);

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final WatchConnectivity _watchConnectivity = WatchConnectivity();
  final TextEditingController _tokenTextController = TextEditingController();
  late String _oauthState;
  StreamSubscription<Uri>? _linkSubscription;

  Future<TokensRepository> get _repo => ref.read(tokensRepoProvider.future);
  // System
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _tokenTextController.dispose();
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async =>
      _linkSubscription = AppLinks().uriLinkStream.listen(_openAppLink);

  // Token
  Future<void> _setToken(Tokens tokens) async {
    (await _repo).setTokens(tokens);
    await _watchConnectivity.updateApplicationContext({'token': tokens.token});
    ref.invalidate(tokensRepoProvider);
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

    await _setToken(Tokens(token: text, refreshToken: null));
  }

  Future<void> _clearToken() async {
    (await _repo).clear();
    await _watchConnectivity.updateApplicationContext({'token': null});
    ref.invalidate(tokensRepoProvider);
    _showSnackBar('Токен сброшен');
  }

  // URL
  void _openLoginUrl() async {
    _oauthState = UuidV4().generate();
    await launchUrlString(Api.loginUrl(_oauthState).toString());
  }

  void _openAppLink(Uri uri) async {
    final queryParams = uri.queryParameters;
    switch (uri.host) {
      case 'tokenredirect':
        if (queryParams case {'code': final code}) {
          final response = await http.get(
            Api.tokenExchangeUrl(code, _oauthState),
          );
          final Map<String, dynamic> json = jsonDecode(response.body);
          log(json.toString());
          await _setToken(Tokens.fromMap(json));
        }
        break;
      default:
        log('Unknown host: ${uri.host}');
    }
    ref.invalidate(tokensRepoProvider);
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
  Widget build(BuildContext context) => FutureBuilder(
    future: _repo,
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const CircularProgressIndicator();
      final repo = snapshot.data!;
      final isLogged = repo.token != null;

      return Scaffold(
        appBar: AppBar(title: const Text('Авторизация часов')),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            spacing: 16,
            children: [
              isLogged ? _buildTokenCard(repo.token!) : _buildLoginButton(),
              if (!isLogged) ...[
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
                    onPressed: value.text.isNotEmpty
                        ? _setTokenFromField
                        : null,
                    style: ElevatedButton.styleFrom(
                      animationDuration: .zero,
                      minimumSize: minBtnSize,
                    ),
                    child: const Text('Ввести токен'),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );

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
      onPressed: null, // () async => await launchUrlString('https://authedu.mosreg.ru/v2/token/refresh'),
      style: OutlinedButton.styleFrom(
        minimumSize: minBtnSize,
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor, width: 1.5),
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
                icon: const Icon(Icons.refresh, size: 16),
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
