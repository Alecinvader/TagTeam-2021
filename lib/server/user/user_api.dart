import 'package:tagteamprod/server/auth_api.dart';
import 'package:tagteamprod/server/errors/error_handler.dart';
import 'package:tagteamprod/server/responses/server_response.dart';
import 'package:tagteamprod/server/user/user_request.dart';

class UserApi {
  final AuthServer api = new AuthServer();

  Future<ServerResponse> createUser(UserRequest request, ErrorHandler handler) async {
    return await api.post('/user/create', {}, request.toJson(), handler, (map) {
      return ServerResponse.fromJson(map);
    });
  }
}
