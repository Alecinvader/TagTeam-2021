import 'package:flutter/material.dart';
import 'package:tagteamprod/models/user.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/team/team_api.dart';
import 'package:tagteamprod/ui/core/tagteam_circleavatar.dart';
import 'package:tagteamprod/ui/core/tagteam_constants.dart';
import 'package:tagteamprod/ui/utility/core/better_future_builder.dart';

class TeamRequests extends StatefulWidget {
  final int teamId;

  const TeamRequests({Key? key, required this.teamId}) : super(key: key);

  @override
  _TeamRequestsState createState() => _TeamRequestsState();
}

class _TeamRequestsState extends State<TeamRequests> {
  late Future<List<User>> requestsFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestsFuture = TeamApi().allJoinRequests(widget.teamId, SnackbarErrorHandler(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Requests'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          child: SimpleFutureBuilder<List<User>>(
              future: requestsFuture,
              builder: (context, data) {
                return ListView.builder(
                  itemBuilder: (context, index) {
                    User currentUser = data![index];

                    return Material(
                      color: kLightBackgroundColor,
                      child: InkWell(
                        onLongPress: () {},
                        child: ListTile(
                          leading: TagTeamCircleAvatar(
                            radius: 20,
                            url: currentUser.profilePicture ?? '',
                          ),
                          title: Row(
                            children: [
                              Expanded(child: Text(currentUser.displayName!)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    height: 30,
                                    child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                            primary: Colors.white,
                                            onSurface: Colors.white,
                                            backgroundColor: Theme.of(context).accentColor),
                                        onPressed: () async {
                                          User? tempUser;
                                          setState(() {
                                            tempUser = data.removeAt(index);
                                          });
                                          await TeamApi().acceptJoinRequest(
                                              widget.teamId,
                                              tempUser!.uid ?? '',
                                              SnackbarErrorHandler(context, onErrorHandler: () {
                                                setState(() {
                                                  data.insert(index, tempUser!);
                                                });
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Could not accept request, try again.')));
                                              }));
                                        },
                                        child: Text('Accept', style: TextStyle(color: Colors.white))),
                                  ),
                                  SizedBox(
                                    width: 12.0,
                                  ),
                                  SizedBox(
                                    height: 30,
                                    child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          primary: Colors.white,
                                          onSurface: Colors.white,
                                          side: BorderSide(color: Colors.white),
                                        ),
                                        onPressed: () async {
                                          User? tempUser;
                                          setState(() {
                                            tempUser = data.removeAt(index);
                                          });
                                          await TeamApi().deleteJoinRequest(
                                              widget.teamId,
                                              tempUser!.uid ?? '',
                                              SnackbarErrorHandler(context, onErrorHandler: () {
                                                setState(() {
                                                  data.insert(index, tempUser!);
                                                });
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Could not deny request, try again.')));
                                              }));
                                        },
                                        child: Text('Deny', style: TextStyle(color: Colors.white))),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: data!.length,
                );
              }),
        ),
      ),
    );
  }

  Future<void> acceptRequest(String uid) async {}
}
