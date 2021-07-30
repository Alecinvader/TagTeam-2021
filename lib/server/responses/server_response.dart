class ServerResponse {
  String? message;

  ServerResponse.fromJson(Map json) {
    message = json['message'];
  }
}
