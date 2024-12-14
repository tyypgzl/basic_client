# Basic Client

A basic Flutter network client for making HTTP requests with support for various HTTP methods and logging.

## Features

- GET, POST, PUT, PATCH, DELETE requests
- JSON parsing
- Logging of requests and responses
- Customizable headers and query parameters

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
    basic_client: ^1.0.0
```

Then run `flutter pub get` to install the package.

## Usage

### Basic Setup

```dart
import 'package:basic_client/basic_client.dart';

void main() {
    final manager = BasicNetworkManager(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        level: LogLevel.all,
    );

    // Use the manager to make requests
}
```

### Making Requests

#### GET Request

```dart
final response = await manager.get<PostResponse, List<PostResponse>>(
    '/posts',
    response: PostResponse(),
);

if (response is BasicSuccess<List<PostResponse>>) {
    print('Posts: ${response.data}');
} else if (response is BasicFailure) {
    print('Error: ${response.errorMessage}');
}
```

#### POST Request

```dart
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

if (response is BasicSuccess<PostResponse>) {
    print('Created Post: ${response.data}');
} else if (response is BasicFailure) {
    print('Error: ${response.errorMessage}');
}
```

#### PUT Request

```dart
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

if (response is BasicSuccess<PostResponse>) {
    print('Updated Post: ${response.data}');
} else if (response is BasicFailure) {
    print('Error: ${response.errorMessage}');
}
```

#### PATCH Request

```dart
final request = PostRequest(
    title: 'foo',
);
final response = await manager.patch<PostResponse, PostResponse>(
    '/posts/1',
    response: PostResponse(),
    body: request.toJson(),
    headers: {
        'Content-type': 'application/json; charset=UTF-8',
    },
);

if (response is BasicSuccess<PostResponse>) {
    print('Patched Post: ${response.data}');
} else if (response is BasicFailure) {
    print('Error: ${response.errorMessage}');
}
```

#### DELETE Request

```dart
final response = await manager.delete<PostResponse, PostResponse>(
    '/posts/1',
    response: PostResponse(),
);

if (response is BasicSuccess<PostResponse>) {
    print('Deleted Post');
} else if (response is BasicFailure) {
    print('Error: ${response.errorMessage}');
}
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.