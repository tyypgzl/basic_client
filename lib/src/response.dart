sealed class BasicResponse<T> {
  const BasicResponse(
    this.statusCode,
    this.contentLength,
    this.headers,
  );
  final int statusCode;
  final int? contentLength;
  final Map<String, dynamic> headers;
}

final class BasicSuccess<T> extends BasicResponse<T> {
  const BasicSuccess({
    required this.data,
    required int statusCode,
    required Map<String, dynamic> headers,
    int? contentLength,
  }) : super(statusCode, contentLength, headers);
  final T data;
}

final class BasicFailure<T> extends BasicResponse<T> {
  const BasicFailure({
    required this.errorMessage,
    required int statusCode,
    required Map<String, dynamic> headers,
    this.error,
    int? contentLength,
  }) : super(statusCode, contentLength, headers);
  final String errorMessage;
  final Object? error;
}
