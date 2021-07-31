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

  Future<ServerResponse> setActiveTeam(int id, ErrorHandler handler) async {
    return await api.get('/team/$id/setactive', {}, handler, (Map json) {
      return ServerResponse.fromJson(json);
    });
  }
}
