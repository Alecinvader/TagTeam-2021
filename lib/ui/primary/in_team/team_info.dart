import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagteamprod/models/provider/team_auth_notifier.dart';
import 'package:tagteamprod/models/tagteam.dart';
import 'package:tagteamprod/ui/core/tagteam_constants.dart';

class TeamInfo extends StatefulWidget {
  TeamInfo({Key? key}) : super(key: key);

  @override
  _TeamInfoState createState() => _TeamInfoState();
}

class _TeamInfoState extends State<TeamInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text('Team Info'),
      ),
      backgroundColor: kLightBackgroundColor,
      body: Consumer<TeamAuthNotifier>(builder: (context, teamData, _) {
        return SafeArea(
          child: Container(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                  child: ListTile(
                    title: Text(teamData.currentTeam?.inviteCode ?? 'No code'),
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
