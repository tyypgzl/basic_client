import 'dart:io';

import 'package:cronet_http/cronet_http.dart' as cronet;
import 'package:cupertino_http/cupertino_http.dart' as cupertino;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as io_client;

final class BasicClient extends http.BaseClient {
  BasicClient({
    this.userAgent,
  }) {
    _httpClient = _createHttpClient();
  }
  late final http.BaseClient _httpClient;

  /// controls the User-Agent header.
  final String? userAgent;

  http.BaseClient _createHttpClient() {
    if (Platform.isAndroid) {
      final engine = cronet.CronetEngine.build(
        userAgent: userAgent,
      );
      return cronet.CronetClient.fromCronetEngine(engine);
    } else if (Platform.isIOS) {
      final config =
          cupertino.URLSessionConfiguration.ephemeralSessionConfiguration();
      if (userAgent != null) {
        config.httpAdditionalHeaders = {
          'User-Agent': userAgent!,
        };
      }

      return cupertino.CupertinoClient.defaultSessionConfiguration();
    } else {
      return io_client.IOClient();
    }
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _httpClient.send(request);

  @override
  void close() {
    _httpClient.close();
    super.close();
  }
}
