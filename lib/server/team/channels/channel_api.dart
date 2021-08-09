import 'package:tagteamprod/models/user.dart';

import '../../../models/channel.dart';
import '../../../models/message.dart';
import '../../auth_api.dart';
import '../../errors/error_handler.dart';
import '../../parsing.dart';
import '../../responses/server_response.dart';

class ChannelApi {
  final AuthServer api = AuthServer();

  Future<ServerResponse> setChannelActive(int channelId, int teamId, ErrorHandler handler) async {
    return await api.get('/channel/setactive/$teamId/$channelId', {}, handler, (map) {
      return ServerResponse.fromJson(map);
    });
  }

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

  Future<ServerResponse> createChannels(List<Channel> channels, int teamId, ErrorHandler handler) async {
    return await api.post('/channel/$teamId', {},
        {'channels': List.generate(channels.length, (index) => channels[index].toJson())}, handler, (map) {
      return ServerResponse.fromJson(map);
    });
  }

  Future<List<User>> getChannelUsers(int channelId, ErrorHandler handler) async {
    return await api.get('/channel/$channelId/users', {}, handler, (map) {
      return parseJsonList(map['users'], (json) => User.fromJson(json));
    });
  }

  Future<ServerResponse> removeUserFromChannel(String userId, int channelId, ErrorHandler handler) async {
    return await api.delete('/channel/removeuser/$channelId/$userId', {}, {}, handler, (map) {
      return ServerResponse.fromJson(map);
    });
  }

  Future<ServerResponse> addUserToChannel(String userId, int channelId, ErrorHandler handler) async {
    return await api.post('/channel/adduser/$channelId/$userId', {}, {}, handler, (map) {
      return ServerResponse.fromJson(map);
    });
  }

  Future<ServerResponse> toggleNotifications(int channelId, ErrorHandler handler) async {
    return await api.get('/channel/$channelId/togglenotifications', {}, handler, (map) {
      return ServerResponse.fromJson(map);
    });
  }

  Future<bool> checkNotificationSettings(int channelId, ErrorHandler handler) async {
    return await api.get('/channel/$channelId/notifications', {}, handler, (map) {
      int value = map['enabled'];
      if (value == 1) return true;
      return false;
    });
  }
}
