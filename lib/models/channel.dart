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
  bool? allowImageSending;

  Message? mostRecentMessage;

  List<User> users = [];

  Channel();

  // TODO: Parse channel Types
  toJson() {
    return {
      "name": name,
      "teamID": teamId,
      "type": type.toString(),
      // "users": List.generate(users.length, (index) => users[index].uid),
      "public": public == true ? 1 : 0,
      "allowImages": allowImageSending == true ? 1 : 0
    };
  }

  Channel.fromJson(Map json) {
    id = json['ID'];
    teamId = json['teamID'];
    firebaseId = json['firebaseID'];
    name = json['name'];
    allowImageSending = json['allowImages'] == 1 ? true : false;
    type = parseChannelType(json['type']);
    public = json['public'] == 1 ? true : false;
    mostRecentMessage = json['mostRecentMessage'] != null ? Message.fromJson(json['mostRecentMessage']) : null;
  }

  parseChannelType(String value) {
    if (value == 'ChannelType.message') {
      return ChannelType.message;
    } else if (value == 'ChannelType.announcment') {
      return ChannelType.announcment;
    } else
      return ChannelType.message;
  }
}
