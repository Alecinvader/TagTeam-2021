import '../auth_api.dart';
import '../errors/error_handler.dart';
import '../responses/server_response.dart';
import 'user_request.dart';

class UserApi {
  final AuthServer api = new AuthServer();

  Future<ServerResponse> createUser(UserRequest request, ErrorHandler handler) async {
    return await api.post('/user/create', {}, request.toJson(), handler, (map) {
      return ServerResponse.fromJson(map);
    });
  }

  Future<ServerResponse> updateFCMToken(String token, String userId, ErrorHandler handler) async {
    return await api.patch(
        '/user/$userId/update/token', {}, {'token': token}, handler, (map) => ServerResponse.fromJson(map));
  }
}
