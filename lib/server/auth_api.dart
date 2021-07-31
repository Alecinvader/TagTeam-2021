import 'package:firebase_auth/firebase_auth.dart';
import 'errors/error_type.dart';
import 'safe_server.dart';

import 'base_api.dart';
import 'errors/error_handler.dart';

const String AuthHeaderKey = 'Authorization';

/// Decorator for [SafeServer] that automatically
///   * Adds auth credentials
///   * Retries on accessToken expiration
///   * Uses [ErrorHandlers] to handle all errors
class AuthServer implements SafeServer {
  SafeServer safeServer = new SafeServer();

  @override
  Future<Result> get<Result>(String url, Map<String, String> headers, ErrorHandler errorHandler,
      ValueChanger<Map<String, dynamic>, Result> responseParser) async {
    try {
      // attempt to make the first request
      await addCredentials(headers);
      final firstAttempt = await unsafeServer.get(url, headers, responseParser);
      return firstAttempt;
    } catch (error) {
      // if authentication error, retry with new credentials
      // if (error is XenonError && error.message == ServerErrorStatus.noauth) {
      //   final authHeaders = await updateCredentials(headers, errorHandler);
      //   return safeServer.get(url, authHeaders, errorHandler, responseParser);
      // }

      // if the error was something else, handle it
      errorHandler.onError(error);
      throw error;
    }
  }

  @override
  Future<Result> post<Result>(String url, Map<String, String> headers, Map<String, dynamic>? body,
      ErrorHandler errorHandler, ValueChanger<Map<String, dynamic>, Result> responseParser) async {
    try {
      // attempt to make the first request
      await addCredentials(headers);
      final firstAttempt = await unsafeServer.post(url, headers, body, responseParser);
      return firstAttempt;
    } catch (error) {
      // if authentication error, retry with new credentials
      // if (error is XenonError && error.message == ServerErrorStatus.noauth) {
      //   final authHeaders = await updateCredentials(headers, errorHandler);
      //   return safeServer.post(url, authHeaders, body, errorHandler, responseParser);
      // }
      // if the error was something else, handle it
      errorHandler.onError(error);

      throw error;
    }
  }

  // @override
  // Future<Result> sendFile<Result>(
  //   String url,
  //   String fieldName,
  //   String filepath,
  //   ErrorHandler errorHandler,
  //   ValueChanger<Map<String, dynamic>, Result> responseParser,
  // ) {
  //   // can you send headers in this kind of request?

  //   return safeServer.sendFile(
  //     url,
  //     fieldName,
  //     filepath,
  //     errorHandler,
  //     responseParser,
  //   );
  // }

  @override
  Api get unsafeServer => safeServer.unsafeServer;

  /// Adds credentials to the [headers] from the [LocalDataService]
  Future<Map<String, String>> addCredentials(Map<String, String> headers) async {
    String? accessToken = await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';

    if (accessToken.isEmpty) {
      throw ServerError('Access token does not exist');
    }

    headers[AuthHeaderKey] = 'Bearer $accessToken';
    headers['Content-Type'] = 'application/json; charset=UTF-8';
    return headers;
  }

  /// Adds updated credentials to the [headers] from the [AuthService]
  // Future<Map<String, String>> updateCredentials(
  //   Map<String, String> headers,
  //   ErrorHandler errorHandler,
  // ) async {

  //   String? accessToken = localData.accessToken;
  //   String? refreshToken = localData.refreshToken;

  //   try {
  //     await unsafeServer.post('/token/refresh', {}, {'RefreshToken': refreshToken, 'AccessToken': accessToken}, (map) {
  //       LocalData().changeAccessToken(map['AccessToken']);
  //       LocalData().changeRefreshToken(map['RefreshToken']);
  //     });
  //   } catch (error) {
  //     errorHandler.onError(error);
  //     errorHandler.showReLoginDialog();
  //     throw error;
  //   }

  //   return addCredentials(headers);

  //   // return headers.map<String, String>((key, value) {
  //   //   if (key == AuthHeaderKey) {
  //   //     return new MapEntry<String, String>(
  //   //       AuthHeaderKey,
  //   //       'Bearer $accessToken',
  //   //     );
  //   //   } else {
  //   //     return new MapEntry<String, String>(key, value);
  //   //   }
  //   // });
  // }

  @override
  Future<Result> delete<Result>(String url, Map<String, String> headers, Map<String, dynamic> body,
      ErrorHandler errorHandler, ValueChanger<Map<String, dynamic>, Result> responseParser) async {
    try {
      // attempt to make the first request
      addCredentials(headers);
      final firstAttempt = await unsafeServer.delete(url, headers, body, responseParser);
      return firstAttempt;
    } catch (error) {
      // if authentication error, retry with new credentials
      // if (error is XenonError && error.message == ServerErrorStatus.noauth) {
      //   final authHeaders = await updateCredentials(headers, errorHandler);
      //   return safeServer.delete(url, authHeaders, body, errorHandler, responseParser);
      // }
      // if the error was something else, handle it
      errorHandler.onError(error);
      throw error;
    }
  }

  @override
  Future<Result> patch<Result>(String url, Map<String, String> headers, Map<String, dynamic>? body,
      ErrorHandler errorHandler, ValueChanger<Map<String, dynamic>, Result> responseParser) async {
    try {
      // attempt to make the first request
      await addCredentials(headers);
      final firstAtttempt = await unsafeServer.patch(url, headers, body, responseParser);
      return firstAtttempt;
    } catch (error) {
      // if authentication error, retry with new credentials
      // if (error is XenonError && error.message == ServerErrorStatus.noauth) {
      //   final authHeaders = await updateCredentials(headers, errorHandler);
      //   return safeServer.patch(url, authHeaders, body, errorHandler, responseParser);
      // }
      // if the error was something else, handle it
      errorHandler.onError(error);
      throw error;
    }
  }
}
