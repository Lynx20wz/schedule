import 'dart:async';
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watch_connectivity/watch_connectivity.dart';

void main() => runApp(
  MaterialApp(home: const PhoneAuthScreen(), theme: .dark(), title: 'Schedule'),
);

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final WatchConnectivity _watchConnectivity = WatchConnectivity();
  final TextEditingController tokenController = TextEditingController();
  String? token;

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  Future<void> _initialize() async => await _loadStoredToken();

  Future<void> _loadStoredToken() async {
    final token = await _getStoredToken();
    setState(() {
      this.token = token;
      if (token != null) {
        tokenController.text = token;
      }
    });
  }

  Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    log((await _watchConnectivity.applicationContext).toString());
    setState(() => this.token = token);
  }

  Future<void> _updateTokenContext() async {
    final text = tokenController.text.trim();
    String? token = text.isNotEmpty ? text : this.token;

    if (token == null) {
      _showSnackBar('Неверный токен');
      return;
    }

    await _watchConnectivity.updateApplicationContext({'token': token});
    _setToken(token);
    _showSnackBar('Токен отправлен на часы');
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await _watchConnectivity.updateApplicationContext({'token': null});

    setState(() {
      token = null;
      tokenController.clear();
    });

    _showSnackBar('Токен удален');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Авторизация часов')),
    body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (token != null) ...[
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Токен сохранен: ${token!.substring(0, 15)}...',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      onPressed: () async =>
                          Clipboard.setData(ClipboardData(text: token!)),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          TextField(
            controller: tokenController,
            decoration: InputDecoration(
              labelText: 'Токен авторизации',
              hintText: 'Введите токен начинающийся с eyJ...',
              border: const OutlineInputBorder(),
              suffixIcon: token != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearToken,
                    )
                  : null,
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 30),

          TextButton(
            onPressed: () async => await launchUrlString(
              'https://authedu.mosreg.ru/v3/auth/esia/login?redirect_url=lynx-schedule://tokenRedirect',
            ),
            child: const Text('Если токена нет'),
          ),

          const SizedBox(height: 30),

          Column(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.watch),
                label: const Text('Отправить токен на часы'),
                onPressed: _updateTokenContext,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              StreamBuilder(
                stream: _watchConnectivity.contextStream,
                builder: (context, snapshot) => Text(snapshot.data.toString()),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
