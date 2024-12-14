enum BasicClientExceptionCode {
  invalidUrl,
  invalidResponse,
  unknown,
}

final class BasicClientException implements Exception {
  const BasicClientException({
    required this.error,
    this.code = BasicClientExceptionCode.unknown,
  });

  /// A message that describes the error.
  final String error;

  /// A code that represents the error.

  final BasicClientExceptionCode code;

  @override
  String toString() {
    return 'BasicClientException: error: $error code: $code';
  }
}
