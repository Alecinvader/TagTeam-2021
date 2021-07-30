import 'dart:async';
import 'dart:convert';

import 'package:tagteamprod/config.dart';
import 'package:tagteamprod/server/server_logger.dart';
import 'package:http/http.dart' as http;
import 'errors/error_handler.dart';

class Api {
  final ServerLogger serverLogger = new ServerLogger();

  String host = EnvConfig().host;

  Future<Result> get<Result>(
    String url,
    Map<String, String> headers,
    ValueChanger<Map<String, dynamic>, Result> responseParser,
  ) async {
    Uri serverUrl = Uri.parse(host + url);
    final response = await http.get(
      serverUrl,
      headers: headers,
    );
    return _common(serverUrl, response, responseParser);
  }

  Future<Result> post<Result>(
    String url,
    Map<String, String> headers,
    Map<String, dynamic>? body,
    ValueChanger<Map<String, dynamic>, Result> responseParser,
  ) async {
    Uri serverUrl = Uri.parse(host + url);
    String requestBody = jsonEncode(body);
    final response = await http.post(
      serverUrl,
      headers: headers,
      body: requestBody,
    );

    return _common(serverUrl, response, responseParser, requestBody: requestBody);
  }

  Future<Result> patch<Result>(
    String url,
    Map<String, String> headers,
    Map<String, dynamic>? body,
    ValueChanger<Map<String, dynamic>, Result> responseParser,
  ) async {
    Uri serverUrl = Uri.parse(host + url);
    String requestBody = jsonEncode(body);
    final response = await http.patch(
      serverUrl,
      headers: headers,
      body: requestBody,
    );
    return _common(serverUrl, response, responseParser, requestBody: requestBody);
  }

  Future<Result> delete<Result>(
    String url,
    Map<String, String> headers,
    Map<String, dynamic> body,
    ValueChanger<Map<String, dynamic>, Result> responseParser,
  ) async {
    Uri serverUrl = Uri.parse(host + url);
    String requestBody = jsonEncode(body);
    final response = await http.delete(
      serverUrl,
      headers: headers,
      body: requestBody,
    );

    return _common(serverUrl, response, responseParser, requestBody: requestBody);
  }

  // Future<Result> sendFile<Result>(
  //   String url,
  //   String fieldName,
  //   String filepath,
  //   ValueChanger<Map<String, dynamic>, Result> responseParser,
  // ) async {
  //   Uri serverUrl = Uri.parse(host + url);
  //   final response = await _sendMulitpartFile(serverUrl, fieldName, filepath);

  //   return responseParser(response);
  //   // return _common(serverUrl, response, responseParser);
  // }

  // Future<String> _sendMulitpartFile(
  //   Uri uri,
  //   String fieldName,
  //   String filepath,
  // ) async {
  //   // Set up the request
  //   final request = http.MultipartRequest("POST", uri);

  //   // Add the specified file to the request
  //   final multipartFile = await http.MultipartFile.fromPath(
  //     fieldName,
  //     filepath,
  //   );
  //   request.files.add(multipartFile);

  //   // Send the stream to the server and wait for a response
  //   final httpStream = await request.send().timeout(
  //     Duration(seconds: 20),
  //     onTimeout: () {
  //       throw TimeoutException('Server Timed out try again later');
  //     },
  //   );
  //   return await httpStream.stream.bytesToString();
  // }

  Result _common<Result>(
      Uri serverUrl, http.Response response, ValueChanger<Map<String, dynamic>, Result> responseParser,
      {String? requestBody}) {
    // Log the interaction with the server
    serverLogger.logInteraction(serverUrl, response.body, request: requestBody);

    if (response.body.isEmpty) {
      throw "Server: Response body is empty";
    }

    int status = response.statusCode;

    // Throw any error that came from the server
    final map = jsonDecode(response.body);

    String message = map['Message'];

    if (status >= 400 && status <= 599) {
      throw "Error: $message";
    } else {
      return responseParser(map);
    }

    // final status = map["Status"];
    // if (status is String && ServerErrorStatus.values.contains(status)) {
    //   throw new ;
    // } else if (!ServerSuccessStatus.values.contains(status)) {
    //   throw "Unknown Error: status $status";
    // } else if (map == '404 page not found') {
    //   throw new XenonError(XenonErrorSource.server, 'error', '404 page not found');
    // } else {
    //   return responseParser(map);
    // }
  }
}
