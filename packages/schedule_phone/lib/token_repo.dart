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
  String? _token;
  String? _refreshToken;

  this
    : _token = _prefs.getString('token'),
      _refreshToken = _prefs.getString('refresh_token');

  String? get token => _token;
  String? get refreshToken => _refreshToken;

  Tokens get tokens => Tokens(token: token!, refreshToken: refreshToken!);

  set token(String? token) {
    token != null ? _prefs.setString('token', token) : _prefs.remove('token');

    _token = token;
  }

  set refreshToken(String? refreshToken) {
    refreshToken != null
        ? _prefs.setString('refresh_token', refreshToken)
        : _prefs.remove('refresh_token');

    _refreshToken = refreshToken;
  }

  void setTokens(Tokens tokens) {
    token = tokens.token;
    refreshToken = tokens.refreshToken;
  }

  void clear() {
    token = null;
    refreshToken = null;
  }
}
