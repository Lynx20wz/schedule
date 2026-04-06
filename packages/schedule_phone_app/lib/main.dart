import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:watch_connectivity/watch_connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() =>
    runApp(MaterialApp(home: const PhoneAuthScreen(), theme: .dark()));

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final WatchConnectivity watchConnectivity = WatchConnectivity();
  final TextEditingController _tokenController = TextEditingController();
  bool _isWatchPaired = false;
  String? _storedToken;
  StreamSubscription? _messageSubscription;
  Stream<Map?>? _messageStream;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _checkWatchConnection();
    await _loadStoredToken();
    log((await watchConnectivity.isReachable).toString());
    _setupMessageListener();
  }

  Future<void> _checkWatchConnection() async {
    final isPaired = await watchConnectivity.isPaired;
    setState(() {
      _isWatchPaired = isPaired;
    });
  }

  Future<void> _loadStoredToken() async {
    final token = await _getStoredToken();
    setState(() {
      _storedToken = token;
      if (token != null) {
        _tokenController.text = token;
      }
    });
  }

  Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  void _setupMessageListener() {
    _messageStream = watchConnectivity.messageStream;
    _messageSubscription = _messageStream!.listen((message) {
      if (message!.containsKey('request_token')) {
        _sendTokenToWatch();
      }
    });
  }

  Future<void> _sendTokenToWatch() async {
    final text = _tokenController.text.trim();
    String? token = text.isNotEmpty ? text : _storedToken;

    if (token == null) {
      _showSnackBar('Неверный токен');
      return;
    }

    await watchConnectivity.sendMessage({'token': token});
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    setState(() {
      _storedToken = null;
      _tokenController.clear();
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
    appBar: AppBar(
      title: const Text('Авторизация часов'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _checkWatchConnection,
          tooltip: 'Проверить подключение',
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    _isWatchPaired ? Icons.watch : Icons.watch_off,
                    color: _isWatchPaired ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isWatchPaired ? 'Часы подключены' : 'Часы не подключены',
                      style: TextStyle(
                        color: _isWatchPaired ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_storedToken != null) ...[
            const SizedBox(height: 10),
            Card(
              color: Colors.green[50],
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
                        'Токен сохранен: ${_storedToken!.substring(0, 15)}...',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Токен скопирован')),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          TextField(
            controller: _tokenController,
            decoration: InputDecoration(
              labelText: 'Токен авторизации',
              hintText: 'Введите токен начинающийся с eyJ...',
              border: const OutlineInputBorder(),
              suffixIcon: _storedToken != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearToken,
                    )
                  : null,
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 30),

          Column(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.watch),
                label: const Text('Отправить токен на часы'),
                onPressed: _sendTokenToWatch,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              StreamBuilder(
                stream: _messageStream,
                builder: (context, snapshot) => Text(snapshot.data.toString()),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
