import 'package:tagteamprod/models/create_team_request.dart';
import 'package:tagteamprod/models/user.dart';

import '../../models/tagteam.dart';
import '../auth_api.dart';
import '../errors/error_handler.dart';
import '../parsing.dart';
import '../responses/server_response.dart';

class TeamApi {
  final AuthServer api = new AuthServer();

  Future<List<TagTeam>> getAllTeams(ErrorHandler handler) async {
    List<TagTeam> temp = [];

    await api.get(
        '/team/all', {}, handler, (map) => {temp = parseJsonList(map['teams'], (json) => TagTeam.fromJson(json))});

    return temp;
  }

  Future<ServerResponse> createTeam(CreateTeamRequest request, ErrorHandler handler) async {
    return await api.post('/team/create', {}, request.toJson(), handler, (map) {
      return ServerResponse.fromJson(map);
    });
  }

  Future<ServerResponse> setActiveTeam(int id, ErrorHandler handler) async {
    return await api.get('/team/$id/setactive', {}, handler, (Map json) {
      return ServerResponse.fromJson(json);
    });
  }

  Future<List<User>> getUsersInTeam(int teamId, ErrorHandler handler) async {
    return await api.get('/team/$teamId/users', {}, handler, (map) {
      return parseJsonList(map['users'], (json) => User.fromJson(json));
    });
  }

  Future<TagTeam> searchByInviteCode(String inviteCode, ErrorHandler handler) async {
    return await api.get('/team/search/$inviteCode', {}, handler, (map) {
      return TagTeam.fromJson(map['team']);
    });
  }

  Future<ServerResponse> requestToJoinTeam(int teamId, ErrorHandler handler) async {
    return await api.get('/team/requestjoin/$teamId', {}, handler, (map) {
      return ServerResponse.fromJson(map);
    });
  }

  Future<List<User>> allJoinRequests(int teamId, ErrorHandler handler) async {
    return await api.get('/team/alljoinrequests/$teamId', {}, handler, (map) {
      return parseJsonList(map['users'], (json) => User.fromJson(json));
    });
  }

  Future<ServerResponse> acceptJoinRequest(int teamId, String userId, ErrorHandler handler) async {
    return await api.get('/team/requestaccept/$userId/$teamId', {}, handler, (map) {
      return ServerResponse.fromJson(map);
    });
  }

  Future<ServerResponse> deleteJoinRequest(int teamId, String uid, ErrorHandler handler) async {
    return await api.delete(('/team/deleterequest/$teamId/$uid'), {}, {}, handler, (map) {
      return ServerResponse.fromJson(map);
    });
  }

  Future<ServerResponse> removeUserFromTeam(int teamId, String uid, ErrorHandler handler) async {
    return await api.delete('/team/removeuser/$teamId/$uid', {}, {}, handler, (map) => ServerResponse.fromJson(map));
  }

  Future<ServerResponse> updateImageLink(int teamId, String link, ErrorHandler handler) async {
    return await api.patch(
        '/team/updateimage/$teamId', {}, {"imageLink": link}, handler, (map) => ServerResponse.fromJson(map));
  }

  Future<ServerResponse> leaveTeam(int teamId, String uid, ErrorHandler handler) async {
    return await api.delete('/team/leaveteam/$teamId/$uid', {}, {}, handler, (map) => ServerResponse.fromJson(map));
  }
}
