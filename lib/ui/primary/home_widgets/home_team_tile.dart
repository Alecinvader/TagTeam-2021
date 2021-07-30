import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:tagteamprod/models/tagteam.dart';

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
    // TODO: implement initState
    super.initState();
    team = widget.team;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        // await context.read<TeamAuth>().setCurrentTeam(team);
        // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => TeamChannels(team: team)));
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
    );
  }
}
