import 'package:riverpod/riverpod.dart';

final tokenProvider = NotifierProvider<TokenNotifier, String?>(
  TokenNotifier.new,
);

class TokenNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setToken(String? token) => state = token;
}
