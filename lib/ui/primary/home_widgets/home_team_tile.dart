import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
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
          await TeamApi().setActiveTeam(
              team.teamId ?? 0, SnackbarErrorHandler(context, overrideErrorMessage: '${team.name} is not available'));

          await Navigator.push(context, MaterialPageRoute(builder: (context) => TeamMessageList(teamId: team.teamId!)));
        },
        child: Container(
          decoration: BoxDecoration(
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
                style: TextStyle(color: Theme.of(context).accentColor, fontSize: 18.0, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
