import 'dart:convert';

import 'package:basic_client/src/client.dart';
import 'package:basic_client/src/exception.dart';
import 'package:basic_client/src/logger.dart';
import 'package:basic_client/src/parser.dart';
import 'package:basic_client/src/response.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

final class BasicNetworkManager {
  BasicNetworkManager({
    required this.baseUrl,
  })  : _client = BasicClient(),
        _logger = const BasicLogger();
  final BasicClient _client;
  final String baseUrl;
  final BasicLogger _logger;

  Future<BasicResponse<Z>> get<T extends BasicResponseParser<T>, Z>(
    String path, {
    required T response,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final startTime = DateTime.now();
      final uri = _parseUri(path, queryParameters: queryParameters);
      _logger.logRequest(uri, 'GET', headers: headers);
      final data = await _client.get(uri, headers: headers);
      _logger.logResponse(
        uri,
        data.statusCode,
        startTime,
        headers: data.headers,
        body: data.body,
      );
      return await _returnResponse<T, Z>(data, response);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        BasicClientException(
          error: '[!] GET - Path: $path - Error: $error',
        ),
        stackTrace,
      );
    }
  }

  Future<BasicResponse<Z>> post<T extends BasicResponseParser<T>, Z>(
    String path, {
    required T response,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Encoding? encoding,
  }) async {
    try {
      final startTime = DateTime.now();
      final uri = _parseUri(path, queryParameters: queryParameters);

      _logger.logRequest(
        uri,
        'POST',
        headers: headers,
        body: body,
      );

      final data = await _client.post(
        uri,
        body: _createRequest(body),
        encoding: encoding,
        headers: headers,
      );

      _logger.logResponse(
        uri,
        data.statusCode,
        startTime,
        headers: data.headers,
        body: data.body,
      );

      return await _returnResponse<T, Z>(
        data,
        response,
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        BasicClientException(
          error: '[!] POST - Path: $path - Error: $error',
        ),
        stackTrace,
      );
    }
  }

  // Delete
  Future<BasicResponse<Z>> delete<T extends BasicResponseParser<T>, Z>(
    String path, {
    required T response,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Encoding? encoding,
  }) async {
    try {
      final startTime = DateTime.now();
      final uri = _parseUri(path, queryParameters: queryParameters);
      _logger.logRequest(
        uri,
        'DELETE',
        headers: headers,
        body: body,
      );
      final data = await _client.delete(
        uri,
        body: _createRequest(body),
        headers: headers,
        encoding: encoding,
      );
      _logger.logResponse(
        uri,
        data.statusCode,
        startTime,
        headers: data.headers,
        body: data.body,
      );

      return await _returnResponse<T, Z>(
        data,
        response,
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        BasicClientException(
          error: '[!] DELETE - Path: $path - Error: $error',
        ),
        stackTrace,
      );
    }
  }

  // Put
  Future<BasicResponse<Z>> put<T extends BasicResponseParser<T>, Z>(
    String path, {
    required T response,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Encoding? encoding,
  }) async {
    try {
      final startTime = DateTime.now();
      final uri = _parseUri(path, queryParameters: queryParameters);
      _logger.logRequest(
        uri,
        'PUT',
        headers: headers,
        body: body,
      );

      final data = await _client.put(
        uri,
        body: _createRequest(body),
        headers: headers,
        encoding: encoding,
      );
      _logger.logResponse(
        uri,
        data.statusCode,
        startTime,
        headers: data.headers,
        body: data.body,
      );

      return await _returnResponse<T, Z>(
        data,
        response,
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        BasicClientException(
          error: '[!] PUT - Path: $path - Error: $error',
        ),
        stackTrace,
      );
    }
  }

  // Patch
  Future<BasicResponse<Z>> patch<T extends BasicResponseParser<T>, Z>(
    String path, {
    required T response,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Encoding? encoding,
  }) async {
    try {
      final startTime = DateTime.now();
      final uri = _parseUri(path, queryParameters: queryParameters);
      _logger.logRequest(
        uri,
        'PATCH',
        headers: headers,
        body: body,
      );

      final data = await _client.patch(
        uri,
        body: _createRequest(body),
        headers: headers,
        encoding: encoding,
      );
      _logger.logResponse(
        uri,
        data.statusCode,
        startTime,
        headers: data.headers,
        body: data.body,
      );

      return await _returnResponse<T, Z>(
        data,
        response,
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        BasicClientException(
          error: '[!] PATCH - Path: $path - Error: $error',
        ),
        stackTrace,
      );
    }
  }

  String _createRequest(Map<String, dynamic>? body) {
    if (body == null) {
      return '';
    }

    return jsonEncode(body);
  }

  Uri _parseUri(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    final queries = queryParameters?.entries.map((entry) {
      return '${entry.key}=${entry.value}';
    }).join('&');
    final query = queries != null ? '?$queries' : '';
    final url = '$baseUrl$path$query';
    final uri = Uri.tryParse(url);
    if (uri != null) {
      return uri;
    } else {
      throw BasicClientException(
        error: '[!] Invalid URL: $url',
        code: BasicClientExceptionCode.invalidUrl,
      );
    }
  }

  dynamic _parseResponse(String body) async {
    try {
      if (body.trim().startsWith('{') || body.trim().startsWith('[')) {
        // Taken from https://github.com/flutter/flutter/blob/135454af32477f815a7525073027a3ff9eff1bfd/packages/flutter/lib/src/services/asset_bundle.dart#L87-L93
        // 50 KB of data should take 2-3 ms to parse on a Moto G4,
        // and about 400 μs on a Pixel 4.
        if (body.codeUnits.length < 50 * 1024) {
          return json.decode(body);
        } else {
          return await compute(json.decode, body);
        }
      } else {
        throw BasicClientException(
          error: '[!] Response is not a valid JSON format. Response: $body',
          code: BasicClientExceptionCode.invalidResponse,
        );
      }
    } on BasicClientException {
      rethrow;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        BasicClientException(
          error: '[!] Response is not a valid JSON format,'
              ' Response: $body, Error: $error',
          code: BasicClientExceptionCode.invalidResponse,
        ),
        stackTrace,
      );
    }
  }

  Future<BasicResponse<Z>> _returnResponse<T extends BasicResponseParser<T>, Z>(
    http.Response data,
    T response,
  ) async {
    final parsed = await _parseResponse(data.body);

    if (parsed is Map<String, dynamic>) {
      return BasicSuccess(
        data: response.fromJson(parsed) as Z,
        statusCode: data.statusCode,
        contentLength: data.contentLength,
        headers: data.headers,
      );
    } else if (parsed is List<dynamic>) {
      return BasicSuccess(
        data: parsed.map((element) {
          return response.fromJson(element as Map<String, dynamic>);
        }).toList() as Z,
        statusCode: data.statusCode,
        headers: data.headers,
      );
    } else {
      throw BasicClientException(
        error:
            '[!] Response is not a valid JSON format. Response: ${data.body}',
        code: BasicClientExceptionCode.invalidResponse,
      );
    }
  }

  void close() {
    _client.close();
  }
}
