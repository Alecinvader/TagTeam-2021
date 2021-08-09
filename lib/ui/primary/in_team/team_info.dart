import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tagteamprod/models/provider/team_auth_notifier.dart';
import 'package:tagteamprod/models/tagteam.dart';
import 'package:tagteamprod/models/user.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/team/team_api.dart';
import 'package:tagteamprod/ui/core/tagteam_constants.dart';
import 'package:tagteamprod/ui/utility/core/better_future_builder.dart';

class TeamInfo extends StatefulWidget {
  TeamInfo({Key? key}) : super(key: key);

  @override
  _TeamInfoState createState() => _TeamInfoState();
}

class _TeamInfoState extends State<TeamInfo> {
  Future<List<User>>? pendingRequestsFuture;

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
        bool isAdmin = false;

        if (teamData.authType == TeamAuthType.manager || teamData.authType == TeamAuthType.owner) {
          isAdmin = true;
          pendingRequestsFuture ??=
              TeamApi().allJoinRequests(teamData.currentTeam!.teamId!, SnackbarErrorHandler(context));
        }

        return SimpleFutureBuilder(
            future: pendingRequestsFuture ?? Future<List<User>>.value([]),
            builder: (context, List<User>? data) {
              return SafeArea(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text('Invite Code'),
                      ),
                      Container(
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                        child: ListTile(
                          title: Text(
                            teamData.currentTeam?.inviteCode ?? 'No code',
                            style: TextStyle(),
                            overflow: TextOverflow.visible,
                          ),
                          trailing: TextButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: teamData.currentTeam?.inviteCode ?? ''));
                              },
                              child: Text('COPY')),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text('Members'),
                      ),
                      Container(
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 35,
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(color: kLightBackgroundColor, shape: BoxShape.circle),
                                child: Center(child: Text(data!.length.toString())),
                              ),
                            ],
                          ),
                          title: Text('Pending Requests'),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                        child: ListTile(
                          leading: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.group_outlined,
                                size: 25,
                                color: Colors.white,
                              )
                            ],
                          ),
                          title: Text('Active Members'),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            });
      }),
    );
  }
}
