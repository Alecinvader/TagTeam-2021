import 'package:firebase_auth/firebase_auth.dart' as fUser;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagteamprod/models/provider/team_auth_notifier.dart';
import 'package:tagteamprod/models/user.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/team/team_api.dart';
import 'package:tagteamprod/ui/core/tagteam_circleavatar.dart';
import 'package:tagteamprod/ui/utility/core/better_future_builder.dart';

class TeamActiveUsers extends StatefulWidget {
  final int teamId;

  TeamActiveUsers({Key? key, required this.teamId}) : super(key: key);

  @override
  _TeamActiveUsersState createState() => _TeamActiveUsersState();
}

class _TeamActiveUsersState extends State<TeamActiveUsers> {
  late Future<List<User>> teamUsersFuture;

  @override
  void initState() {
    super.initState();
    teamUsersFuture = TeamApi().getUsersInTeam(widget.teamId, SnackbarErrorHandler(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Container(
            child: SimpleFutureBuilder<List<User>>(
                future: teamUsersFuture,
                builder: (context, data) {
                  return Consumer<TeamAuthNotifier>(builder: (context, teamData, _) {
                    bool isAdmin = teamData.isAdmin;

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                              itemCount: data!.length,
                              itemBuilder: (context, index) {
                                User currentUser = data[index];

                                return ListTile(
                                  title: Text(currentUser.displayName!),
                                  leading: TagTeamCircleAvatar(
                                    url: currentUser.profilePicture ?? '',
                                    radius: 20,
                                  ),
                                  trailing: currentUser.uid! != fUser.FirebaseAuth.instance.currentUser!.uid && isAdmin
                                      ? TextButton(
                                          onPressed: () async {
                                            late User tempUser;
                                            setState(() {
                                              tempUser = data.removeAt(index);
                                            });

                                            await TeamApi().removeUserFromTeam(
                                                widget.teamId,
                                                currentUser.uid!,
                                                SnackbarErrorHandler(context, onErrorHandler: () {
                                                  setState(() {
                                                    data.insert(index, tempUser);
                                                  });
                                                }));
                                          },
                                          child: Text(
                                            'Remove',
                                            style: TextStyle(color: Colors.red),
                                          ))
                                      : SizedBox(),
                                );
                              }),
                        )
                      ],
                    );
                  });
                })),
      ),
    );
  }
}
