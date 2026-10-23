import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class Tokens({
  required final String access,
  required final String? refresh,
}) {
  this : assert(isValid(access) && (refresh == null || isValid(refresh)));
  factory fromMap(Map<String, dynamic> map) =>
      Tokens(access: map['token'], refresh: map['refresh_token']);
  static bool isValid(String value) => value.startsWith('eyJhb');
}

final tokensProvider = AsyncNotifierProvider<TokensNotifier, Tokens?>(
  TokensNotifier.new,
);

class TokensNotifier extends AsyncNotifier<Tokens?> {
  static const _accessKey = 'token';
  static const _refreshKey = 'refresh_token';

  SharedPreferences? _prefs;

  @override
  Future<Tokens?> build() async {
    final prefs = _prefs = await SharedPreferences.getInstance();
    final access = prefs.getString(_accessKey);
    if (access == null) return null;

    return Tokens(access: access, refresh: prefs.getString(_refreshKey));
  }

  Future<void> setTokens(Tokens tokens) async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, tokens.access);

    final refresh = tokens.refresh;
    await (refresh == null
        ? prefs.remove(_refreshKey)
        : prefs.setString(_refreshKey, refresh));

    state = AsyncData(tokens);
  }

  Future<void> clear() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);

    state = const AsyncData(null);
  }
}
