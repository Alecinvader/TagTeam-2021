import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:tagteamprod/models/provider/team_auth_notifier.dart';
import 'package:tagteamprod/server/responses/server_response.dart';
import '../../../models/tagteam.dart';
import '../../../server/errors/snackbar_error_handler.dart';
import '../../../server/team/team_api.dart';
import '../in_team/team_message_list.dart';

class MiniDashboardTile extends StatefulWidget {
  final TagTeam team;

  const MiniDashboardTile({Key? key, required this.team}) : super(key: key);

  @override
  _MiniDashboardTileState createState() => _MiniDashboardTileState();
}

class _MiniDashboardTileState extends State<MiniDashboardTile> {
  late TagTeam team;

  bool failedToLoadImage = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    team = widget.team;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () async {
          setState(() {
            _isLoading = true;
          });

          final ServerResponse role = await TeamApi().setActiveTeam(
              team.teamId ?? 0,
              SnackbarErrorHandler(context, onErrorHandler: () {
                setState(() {
                  _isLoading = false;
                });
              }, overrideErrorMessage: '${team.name} is not available'));

          await FirebaseAuth.instance.currentUser!.getIdToken(true);

          Provider.of<TeamAuthNotifier>(context, listen: false)
              .setActiveTeam(team, role.message!);

          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TeamMessageList(teamId: team.teamId!)));

          setState(() {
            _isLoading = false;
          });
        },
        child: Container(
          decoration: BoxDecoration(
              image: team.imageLink != null && !failedToLoadImage
                  ? DecorationImage(
                      onError: (object, trace) {},
                      image: NetworkImage(team.imageLink!),
                      fit: BoxFit.cover,
                      colorFilter:
                          ColorFilter.mode(Colors.black54, BlendMode.srcOver))
                  : null,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: .5),
              )),
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 8.0,
              ),
              Container(
                height: 40,
                width: 40,
                child: SizedBox.expand(
                  child: Image.asset(
                    'assets/images/TagTeamLogo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                width: 8.0,
              ),
              Text(
                team.name ?? 'Team Name',
                style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
