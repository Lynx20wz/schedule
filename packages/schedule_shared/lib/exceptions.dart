/// Thrown when the token is not valid or expired.
class TokenInvalidException implements Exception {
  @override
  String toString() {
    return 'Token is not valid or expired';
  }
}
