abstract final class Api {
  static const String _baseUrl = 'https://authedu.mosreg.ru/v3';
  static const String _redirectUrl = 'lynx-schedule://tokenRedirect';

  /// Returns the URL for login.
  static Uri loginUrl(String state) => Uri.parse(
    '$_baseUrl/auth/esia/login?redirect_url=$_redirectUrl&state=$state',
  );

  /// Returns the URL for token exchange with provided code and state.
  static Uri tokenExchangeUrl(String code, String state) =>
      Uri.parse('$_baseUrl/auth/token?code=$code&state=$state');
}
