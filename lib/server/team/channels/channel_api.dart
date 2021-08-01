import '../../../models/channel.dart';
import '../../../models/message.dart';
import '../../auth_api.dart';
import '../../errors/error_handler.dart';
import '../../parsing.dart';
import '../../responses/server_response.dart';

class ChannelApi {
  final AuthServer api = AuthServer();

  Future<List<Channel>> getChannelsForTeam(int teamId, ErrorHandler handler) async {
    return await api.get('/channel/allchannels/$teamId', {}, handler, (map) {
      return parseJsonList(map['channels'], (json) => Channel.fromJson(json));
    });
  }

  Future<ServerResponse> sendMessage(int channelId, int teamId, Message message, ErrorHandler handler) async {
    return await api.post('/channel/$teamId/$channelId/message', {}, message.toJson(), handler, (map) {
      return ServerResponse.fromJson(map);
    });
  }
}
