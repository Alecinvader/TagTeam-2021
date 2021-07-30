import 'dart:async';

import 'base_api.dart';
import 'errors/error_handler.dart';

/// A Decorator for the XenonServer that forces you to use [ErrorHandlers] to handle every error
class SafeServer {
  final Api unsafeServer = new Api();

  Future<Result> get<Result>(
    String url,
    Map<String, String> headers,
    ErrorHandler errorHandler,
    ValueChanger<Map<String, dynamic>, Result> responseParser,
  ) {
    return errorHandler.handleAsync(unsafeServer.get(url, headers, responseParser));
  }

  Future<Result> post<Result>(
    String url,
    Map<String, String> headers,
    Map<String, dynamic>? body,
    ErrorHandler errorHandler,
    ValueChanger<Map<String, dynamic>, Result> responseParser,
  ) {
    return errorHandler.handleAsync(unsafeServer.post(url, headers, body, responseParser));
  }

  Future<Result> patch<Result>(
    String url,
    Map<String, String> headers,
    Map<String, dynamic>? body,
    ErrorHandler errorHandler,
    ValueChanger<Map<String, dynamic>, Result> responseParser,
  ) {
    return errorHandler.handleAsync(unsafeServer.patch(url, headers, body, responseParser));
  }

  Future<Result> delete<Result>(
    String url,
    Map<String, String> headers,
    Map<String, dynamic> body,
    ErrorHandler errorHandler,
    ValueChanger<Map<String, dynamic>, Result> responseParser,
  ) {
    return errorHandler.handleAsync(unsafeServer.delete(url, headers, body, responseParser));
  }

  // Future<Result> sendFile<Result>(
  //   String url,
  //   String fieldName,
  //   String filepath,
  //   ErrorHandler errorHandler,
  //   ValueChanger<Map<String, dynamic>, Result> responseParser,
  // ) async {
  //   return errorHandler.handleAsync(unsafeServer.sendFile(url, fieldName, filepath, responseParser));
  // }
}
