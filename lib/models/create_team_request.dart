import 'package:tagteamprod/models/channel.dart';
import 'package:tagteamprod/models/tagteam.dart';

class CreateTeamRequest {
  TagTeam? team;
  List<Channel>? channels = [];

  CreateTeamRequest({this.team, this.channels});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...team!.toJson(),
      'channels': List.generate(channels?.length ?? 0, (index) => channels![index].toJson())
    };
  }
}
