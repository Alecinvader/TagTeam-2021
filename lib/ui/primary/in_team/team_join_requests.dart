import 'package:flutter/material.dart';
import 'package:tagteamprod/models/user.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/team/team_api.dart';
import 'package:tagteamprod/ui/core/tagteam_circleavatar.dart';
import 'package:tagteamprod/ui/core/tagteam_constants.dart';
import 'package:tagteamprod/ui/utility/core/elevated_async_button.dart';

class JoinRequests extends StatefulWidget {
  final int teamId;

  const JoinRequests({Key? key, required this.teamId}) : super(key: key);

  @override
  _JoinRequestsState createState() => _JoinRequestsState();
}

class _JoinRequestsState extends State<JoinRequests> {
  late Future<List<User>> requestFuture;

  List<User> users = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestFuture = TeamApi().allJoinRequests(widget.teamId, SnackbarErrorHandler(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Requests'),
      ),
      body: SafeArea(
        child: Container(
          child: FutureBuilder(
            future: requestFuture,
            builder: (context, AsyncSnapshot<List<User>> data) {
              if (data.hasData) {
                return ListView.builder(
                    itemCount: data.data!.length,
                    itemBuilder: (context, index) {
                      User currentInfo = data.data![index];

                      return ListTile(
                        contentPadding: EdgeInsets.all(16.0),
                        tileColor: kLightBackgroundColor,
                        leading: TagTeamCircleAvatar(
                          url: currentInfo.profilePicture ?? '',
                        ),
                        title: Text(
                          currentInfo.displayName ?? 'Unknown name',
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: AsyncElevatedButton(
                          buttonStyle: ElevatedButton.styleFrom(
                            primary: Theme.of(context).accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          onPressed: () async {
                            return await TeamApi()
                                .acceptJoinRequest(widget.teamId, currentInfo.uid!, SnackbarErrorHandler(context));
                          },
                          child: Text('Accept'),
                        ),
                      );
                    });
              }

              return Center(child: Text('No Requests'));
            },
          ),
        ),
      ),
    );
  }
}
