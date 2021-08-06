import 'package:tagteamprod/models/user.dart';

import 'message.dart';

enum ChannelType { message, announcment }

class Channel {
  int? id;
  int? teamId;
  String? firebaseId;
  String? name;
  ChannelType? type;
  bool? public;

  Message? mostRecentMessage;

  List<User> users = [];

  Channel();

  // TOOD: Parse channel Types
  toJson() {
    return {
      "name": name,
      "type": "MessageType.message",
      "teamID": teamId,
      "users": List.generate(users.length, (index) => users[index].uid),
      "public": public == true ? 1 : 0
    };
  }

  Channel.fromJson(Map json) {
    id = json['ID'];
    teamId = json['teamID'];
    firebaseId = json['firebaseID'];
    name = json['name'];
    type = ChannelType.message;
    public = json['public'] == 1 ? true : false;
    mostRecentMessage = json['mostRecentMessage'] != null ? Message.fromJson(json['mostRecentMessage']) : null;
  }
}