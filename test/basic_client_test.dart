import 'package:basic_client/basic_client.dart';
import 'package:basic_client/src/logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late BasicNetworkManager manager;

  setUp(() {
    manager = BasicNetworkManager(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      level: LogLevel.all,
    );
  });

  tearDown(() {
    manager.close();
  });

  group('JSONPlaceholder API Tests', () {
    test('Get all Posts', () async {
      final response = await manager.get<PostResponse, List<PostResponse>>(
        '/posts',
        response: PostResponse(),
      );

      expect(response, isA<BasicResponse<List<PostResponse>>>());
      expect(response.statusCode, 200);
      expect(response, isA<BasicSuccess<List<PostResponse>>>());
    });

    test('Get Post by ID', () async {
      final response = await manager.get<PostResponse, PostResponse>(
        '/posts/1',
        response: PostResponse(),
      );

      expect(response, isA<BasicResponse<PostResponse>>());
      expect(response.statusCode, 200);
      expect(response, isA<BasicSuccess<PostResponse>>());
    });

    test('Post a new Post', () async {
      final request = PostRequest(
        userId: 24,
        title: 'foo',
        body: 'bar',
      );
      final response = await manager.post<PostResponse, PostResponse>(
        '/posts',
        response: PostResponse(),
        body: request.toJson(),
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        },
      );

      expect(response, isA<BasicResponse<PostResponse>>());
      expect(response.statusCode, 201);
      expect(response, isA<BasicSuccess<PostResponse>>());
    });

    test('Put a Post', () async {
      final request = PostRequest(
        userId: 24,
        title: 'foo',
        body: 'bar',
      );
      final response = await manager.put<PostResponse, PostResponse>(
        '/posts/1',
        response: PostResponse(),
        body: request.toJson(),
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        },
      );

      expect(response, isA<BasicResponse<PostResponse>>());
      expect(response.statusCode, 200);
      expect(response, isA<BasicSuccess<PostResponse>>());
    });

    test('Patch a Post', () async {
      final request = PostRequest(
        title: 'foo',
      );
      final BasicResponse<PostResponse> response =
          await manager.patch<PostResponse, PostResponse>(
        '/posts/1',
        response: PostResponse(),
        body: request.toJson(),
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        },
      );

      expect(response, isA<BasicResponse<PostResponse>>());
      expect(response.statusCode, 200);
      expect(response, isA<BasicSuccess<PostResponse>>());
      expect((response as BasicSuccess<PostResponse>).data.title, isNotNull);
      expect((response).data.title, 'foo');
      expect(response.statusCode, 200);
    });

    test('Delete a Post', () async {
      final response = await manager.delete<PostResponse, PostResponse>(
        '/posts/1',
        response: PostResponse(),
      );

      expect(response, isA<BasicResponse<PostResponse>>());
      expect(response.statusCode, 200);
      expect(response, isA<BasicSuccess<PostResponse>>());
    });
  });
}

final class PostResponse implements BasicResponseParser<PostResponse> {
  final int? userId;
  final int? id;
  final String? title;
  final String? body;

  PostResponse({
    this.userId,
    this.id,
    this.title,
    this.body,
  });

  PostResponse copyWith({
    int? userId,
    int? id,
    String? title,
    String? body,
  }) {
    return PostResponse(
      userId: userId ?? this.userId,
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      userId: json['userId'] as int?,
      id: json['id'] as int?,
      title: json['title'] as String?,
      body: json['body'] as String?,
    );
  }

  @override
  PostResponse fromJson(Map<String, dynamic> json) =>
      PostResponse.fromJson(json);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostResponse &&
        other.userId == userId &&
        other.id == id &&
        other.title == title &&
        other.body == body;
  }

  @override
  int get hashCode =>
      userId.hashCode ^ id.hashCode ^ title.hashCode ^ body.hashCode;
}

final class PostRequest implements BasicRequestParser {
  final int? userId;
  final String? title;
  final String? body;

  PostRequest({
    this.userId,
    this.title,
    this.body,
  });

  PostRequest copyWith({
    int? userId,
    String? title,
    String? body,
  }) {
    return PostRequest(
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostRequest &&
        other.userId == userId &&
        other.title == title &&
        other.body == body;
  }

  @override
  int get hashCode => userId.hashCode ^ title.hashCode ^ body.hashCode;
}
