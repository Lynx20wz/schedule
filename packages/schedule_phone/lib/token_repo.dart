import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class Tokens({
  required final String token,
  required final String? refreshToken,
}) {
  this
    : assert(isValid(token) && (refreshToken == null || isValid(refreshToken)));
  factory fromMap(Map<String, dynamic> map) =>
      Tokens(token: map['token'], refreshToken: map['refresh_token']);
  static bool isValid(String value) => value.startsWith('eyJhb');
}

class TokensRepository(final SharedPreferences _prefs) {
  String? get token => _prefs.getString('token');
  String? get refreshToken => _prefs.getString('refresh_token');

  Tokens get tokens => Tokens(token: token!, refreshToken: refreshToken);

  set token(String? token) =>
      token != null ? _prefs.setString('token', token) : _prefs.remove('token');

  set refreshToken(String? refreshToken) => refreshToken != null
      ? _prefs.setString('refresh_token', refreshToken)
      : _prefs.remove('refresh_token');

  void setTokens(Tokens tokens) {
    token = tokens.token;
    refreshToken = tokens.refreshToken;
  }

  void clear() {
    token = null;
    refreshToken = null;
  }
}

final tokensRepoProvider = FutureProvider<TokensRepository>(
  (ref) async => TokensRepository(await SharedPreferences.getInstance()),
);
