import 'dart:async';
import 'dart:convert' show jsonDecode;
import 'dart:developer' show log;

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:schedule_phone/api.dart';
import 'package:schedule_phone/token_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/v4.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

void main() => runApp(
  MaterialApp(
    title: 'Schedule',
    theme: .from(
      colorScheme: .fromSeed(seedColor: Colors.blue, brightness: .dark),
    ),
    home: const PhoneAuthScreen(),
  ),
);

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final WatchConnectivity _watchConnectivity = WatchConnectivity();
  final TextEditingController _tokenTextController = TextEditingController();
  late final TokensRepository _repo;
  late String _oauthState;
  StreamSubscription<Uri>? _linkSubscription;

  bool get _isLogged => _repo.token != null;

  // System
  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  void dispose() {
    _tokenTextController.dispose();
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    _linkSubscription = AppLinks().uriLinkStream.listen(
      (uri) => _openAppLink(uri),
    );
    final prefs = await SharedPreferences.getInstance();
    setState(() => _repo = TokensRepository(prefs));
  }

  // Token
  Future<void> _setToken(Tokens tokens) async {
    _repo.setTokens(tokens);
    await _watchConnectivity.updateApplicationContext({'token': tokens.token});
    setState(() {});
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
    _repo.clear();
    await _watchConnectivity.updateApplicationContext({'token': null});
    setState(() {});
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
    setState(() {});
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Авторизация часов')),
    body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        spacing: 16,
        children: [
          _isLogged ? _buildTokenCard() : _buildLoginButton(),
          if (!_isLogged) ...[
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
                onPressed: value.text.isNotEmpty ? _setTokenFromField : null,
                style: ElevatedButton.styleFrom(
                  animationDuration: .zero,
                  minimumSize: const Size(double.infinity, 60),
                ),
                child: const Text('Ввести токен'),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _buildLoginButton() => FilledButton.icon(
    icon: const Icon(Icons.login),
    label: const Text('Войти'),
    onPressed: _openLoginUrl,
    style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 60)),
  );

  Widget _buildTokenCard() => Card(
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Токен сохранен: ${_repo.token!.substring(0, 15)}...',
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
                    Clipboard.setData(ClipboardData(text: _repo.token!)),
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
