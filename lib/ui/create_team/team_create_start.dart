import 'package:flutter/material.dart';
import 'package:tagteamprod/models/channel.dart';
import 'package:tagteamprod/models/create_team_request.dart';
import 'package:tagteamprod/models/tagteam.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/team/team_api.dart';
import 'package:tagteamprod/ui/core/success_snackbar.dart';
import 'package:tagteamprod/ui/core/tagteam_constants.dart';
import 'package:tagteamprod/ui/create_team/team_next_button.dart';
import 'package:tagteamprod/ui/primary/channels/create_single_channel.dart';

import 'team_create_channels.dart';

class TeamBasicDetails extends StatefulWidget {
  const TeamBasicDetails({Key? key}) : super(key: key);

  @override
  _TeamBasicDetailsState createState() => _TeamBasicDetailsState();
}

class _TeamBasicDetailsState extends State<TeamBasicDetails> {
  String teamName = '';

  TagTeam team = new TagTeam();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 36.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Whats your team called?',
                style: kTeamPageTitle,
              ),
              TextField(
                onChanged: (String value) {
                  setState(() {
                    teamName = value;
                  });
                },
                decoration: InputDecoration(
                    hintText: '"Morning Team 2"',
                    hintStyle: TextStyle(color: Colors.white60),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).accentColor))),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleNextButton(
                    onPressed: createTeam,
                    enabled: teamName.isNotEmpty && !isLoading,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createTeam() async {
    Channel? channel = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateSingleChannel()));

    team.name = teamName;

    setState(() {
      isLoading = true;
    });

    SuccessSnackBar(context, widget: Text('Team will be created shortly')).showSnackbar(context);

    int count = 0;
    Navigator.popUntil(context, (route) {
      return count++ == 3;
    });

    await TeamApi().createTeam(
        CreateTeamRequest(team: team, channels: channel != null ? [channel] : []),
        SnackbarErrorHandler(context, onErrorHandler: () {
          setState(() {
            isLoading = false;
          });
        }));
  }
}
