import 'package:flutter/material.dart';
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
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateSingleChannel()));
                    },
                    enabled: teamName.isNotEmpty,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
