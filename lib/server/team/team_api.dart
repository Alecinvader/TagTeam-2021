import 'package:tagteamprod/models/tagteam.dart';
import 'package:tagteamprod/server/auth_api.dart';
import 'package:tagteamprod/server/errors/error_handler.dart';
import 'package:tagteamprod/server/parsing.dart';

class TeamApi {
  final AuthServer api = new AuthServer();

  Future<List<TagTeam>> getAllTeams(ErrorHandler handler) async {
    List<TagTeam> temp = [];

    await api.get(
        '/team/all', {}, handler, (map) => {temp = parseJsonList(map['teams'], (json) => TagTeam.fromJson(json))});

    return temp;
  }
}
