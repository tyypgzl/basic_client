import 'dart:convert';
import 'dart:developer' as developer;

enum LogLevel {
  /// No logs will be printed.
  none,

  /// Only basic logs will be printed.
  basic,

  /// Headers will be printed.
  headers,

  ///
  body,
  all,
}

final class BasicLogger {
  const BasicLogger({
    this.level = LogLevel.basic,
  });

  final LogLevel level;

  void logRequest(
    Uri url,
    String method, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    DateTime? startTime,
  }) {
    if (level == LogLevel.none) return;

    final log = StringBuffer()
      ..writeln('┌── Request ─────────────────────────────')
      ..writeln('│ $method $url');

    if (level.index >= LogLevel.headers.index && headers != null) {
      log.writeln('│ Headers:');
      headers.forEach((key, value) {
        log.writeln('│   $key: $value');
      });
    }

    if (level.index >= LogLevel.body.index && body != null) {
      log
        ..writeln('│ Body:')
        ..writeln('│   ${_prettyJson(body)}');
    }

    developer.log(log.toString(), name: 'BasicClient');
  }

  void logResponse(
    Uri url,
    int statusCode,
    DateTime startTime, {
    Map<String, String>? headers,
    dynamic body,
    Object? error,
  }) {
    if (level == LogLevel.none) return;

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    final log = StringBuffer()
      ..writeln('├── Response ────────────────────────────')
      ..writeln('│ Status: $statusCode')
      ..writeln('│ Duration: ${duration.inMilliseconds}ms');

    if (level.index >= LogLevel.headers.index && headers != null) {
      log.writeln('│ Headers:');
      headers.forEach((key, value) {
        log.writeln('│   $key: $value');
      });
    }

    if (level.index >= LogLevel.body.index && body != null) {
      log
        ..writeln('│ Body:')
        ..writeln('│   ${_prettyJson(body)}');
    }

    if (error != null) {
      log
        ..writeln('│ Error:')
        ..writeln('│   $error');
    }

    log.writeln('└─────────────────────────────────────');
    developer.log(log.toString(), name: 'BasicClient');
  }

  String _prettyJson(dynamic json) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (e) {
      return json.toString();
    }
  }
}
