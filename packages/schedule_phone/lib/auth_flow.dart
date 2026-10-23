import 'dart:async';
import 'dart:convert' show jsonDecode;
import 'dart:developer' show log;

import 'package:app_links/app_links.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/v4.dart';

import 'api.dart';
import 'token_repo.dart';

final authFlowProvider = Provider<AuthFlow>((ref) {
  final flow = AuthFlow(ref);
  ref.onDispose(flow.dispose);
  return flow;
});

class AuthFlow {
  AuthFlow(this._ref) {
    _linkSubscription = AppLinks().uriLinkStream.listen(_handleUri);
  }

  final Ref _ref;
  StreamSubscription<Uri>? _linkSubscription;
  String? _oauthState;

  Future<void> login() async {
    final state = UuidV4().generate();
    _oauthState = state;
    await launchUrlString(Api.loginUrl(state).toString());
  }

  Future<void> _handleUri(Uri uri) async {
    if (uri.host != 'tokenredirect') {
      log('Unknown deeplink host: ${uri.host}', name: 'AuthFlow._handleUri');
      return;
    }

    final code = uri.queryParameters['code'];
    final state = _oauthState;

    if (code == null || state == null) {
      log(
        'OAuth callback is missing code or state',
        name: 'AuthFlow._handleUri',
      );
      return;
    }

    try {
      final response = await http.get(Api.tokenExchangeUrl(code, state));
      final Map<String, dynamic> json = jsonDecode(response.body);
      log(json.toString(), name: 'AuthFlow._handleUri');

      await _ref.read(tokensProvider.notifier).setTokens(Tokens.fromMap(json));
    } catch (e, st) {
      log(
        'Token exchange failed: $e',
        name: 'AuthFlow._handleUri',
        stackTrace: st,
        error: e,
      );
    }
  }

  void dispose() => _linkSubscription?.cancel();
}
