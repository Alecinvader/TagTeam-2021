import 'package:firebase_auth/firebase_auth.dart' as fbauth;
import 'package:tagteamprod/models/user.dart';
import 'package:tagteamprod/server/parsing.dart';

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

  Future<ServerResponse> updateFCMToken(String? token, String userId, ErrorHandler handler) async {
    return await api.patch(
        '/user/$userId/update/token', {}, {'token': token}, handler, (map) => ServerResponse.fromJson(map));
  }

  Future<User> getUser(String uid, ErrorHandler handler) async {
    return await api.get('/user/$uid', {}, handler, (map) {
      return User.fromJson(map['user']);
    });
  }

  Future<ServerResponse> updateUserImage(String uid, String imageLink, ErrorHandler handler) async {
    return await api.patch(
        '/user/$uid/update/image', {}, {"profilePicture": imageLink}, handler, (map) => ServerResponse.fromJson(map));
  }

  Future<ServerResponse> blockUser(String blockedUid, ErrorHandler handler) async {
    String uid = fbauth.FirebaseAuth.instance.currentUser!.uid;
    print(uid);
    return await api.get('/user/$uid/block/$blockedUid', {}, handler, (map) => ServerResponse.fromJson(map));
  }

  Future<List<User>> getBlockedUsers(ErrorHandler handler) async {
    String uid = fbauth.FirebaseAuth.instance.currentUser!.uid;
    return await api.get(
        '/user/$uid/blockedusers', {}, handler, (map) => parseJsonList(map['users'], (json) => User.fromJson(json)));
  }

  Future<ServerResponse> acceptEULA(ErrorHandler handler) async {
    String uid = fbauth.FirebaseAuth.instance.currentUser!.uid;
    return await api.get('/user/$uid/accepteula', {}, handler, (map) {
      return ServerResponse.fromJson(map);
    });
  }
}
