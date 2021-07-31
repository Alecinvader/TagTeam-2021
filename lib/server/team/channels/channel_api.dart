import 'package:tagteamprod/models/channel.dart';
import 'package:tagteamprod/models/message.dart';
import 'package:tagteamprod/server/auth_api.dart';
import 'package:tagteamprod/server/errors/error_handler.dart';
import 'package:tagteamprod/server/parsing.dart';
import 'package:tagteamprod/server/responses/server_response.dart';

class ChannelApi {
  final AuthServer api = AuthServer();

  Future<List<Channel>> getChannelsForTeam(int teamId, ErrorHandler handler) async {
    return await api.get('/channel/allchannels/$teamId', {}, handler, (map) {
      return parseJsonList(map['channels'], (json) => Channel.fromJson(json));
    });
  }

  Future<ServerResponse> sendMessage(int channelId, Message message, ErrorHandler handler) async {
    return await api.post('/channel/$channelId/message', {}, message.toJson(), handler, (map) {
      return ServerResponse.fromJson(map);
    });
  }
}
