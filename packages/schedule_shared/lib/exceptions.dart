abstract class TokenException implements Exception {
  @override
  String toString();
}

/// Thrown when the token is not valid or expired.
class TokenInvalidException implements TokenException {
  const TokenInvalidException();

  @override
  String toString() => 'Token is not valid or expired';
}

class TokenNotFound implements TokenException {
  const TokenNotFound();

  @override
  String toString() => 'Token is not found';
}
