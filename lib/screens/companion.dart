import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final FlutterWearOsConnectivity _connectivity = FlutterWearOsConnectivity();
  StreamSubscription<CapabilityInfo>? _connectedDeviceSub;
  WearOsDevice? _selectedDevice;

  @override
  void initState() {
    super.initState();
    _connectivity.configureWearableAPI().then((_) {
      _connectivity.getAllDataItems();
      _connectedDeviceSub = _connectivity
          .capabilityChanged(
            capabilityPathURI: Uri(
              scheme: 'wear',
              host: '*',
              path: '/smart_watch_connected',
            ),
          )
          .listen((info) {
            if (info.associatedDevices.isEmpty) {
              setState(() {
                _selectedDevice = null;
              });
            }
          });
    });
    _connectivity
        .messageReceived(
          pathURI: Uri(
            scheme: 'wear',
            host: _selectedDevice?.id,
            path: '/request_token',
          ),
        )
        .listen((message) => _sendTokenToWatch());
  }

  @override
  void dispose() {
    super.dispose();
    _connectivity.dispose();
    _connectedDeviceSub?.cancel();
  }

  void _sendTokenToWatch() async {
    final token = await _getStoredToken();
    if (token != null) {
      await _connectivity.sendMessage(
        Uint8List.fromList(utf8.encode(token)),
        deviceId: _selectedDevice!.id,
        path: '/send_token',
      );
    }
  }

  Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  void _extractAndSaveToken() async {
    throw UnimplementedError();
    // final token = 'extracted_token_here';
    // await _saveToken(token);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Авторизация')),
      body: Text(_selectedDevice?.name ?? 'Устройство не подключено'),
    );
  }
}
