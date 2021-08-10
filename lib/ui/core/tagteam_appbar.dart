import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagteamprod/models/provider/team_auth_notifier.dart';
import 'package:tagteamprod/ui/core/tagteam_circleavatar.dart';
import 'package:tagteamprod/ui/primary/in_team/team_info.dart';
import 'tagteam_constants.dart';

class TagTeamAppBar extends StatefulWidget {
  final String title;
  final VoidCallback onTap;
  final String? imageUrl;

  const TagTeamAppBar({Key? key, required this.onTap, required this.title, this.imageUrl}) : super(key: key);

  @override
  _CustomAppbarState createState() => _CustomAppbarState();
}

class _CustomAppbarState extends State<TagTeamAppBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        height: kToolbarHeight,
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: kLightBackgroundColor,
          elevation: 4.0,
          child: InkWell(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            onTap: () {
              widget.onTap();
            },
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                      Text(widget.title, style: TextStyle(color: Colors.white70, fontSize: 16.0)),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer<TeamAuthNotifier>(builder: (context, data, _) {
                    return GestureDetector(
                      onTap: () {
                        // final teamId = Provider.of<TeamAuth>(context, listen: false).team.id;
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TeamInfo()));
                      },
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Hero(
                            tag: 'appbar-icon',
                            child: Padding(
                              padding: EdgeInsets.only(right: 16.0, left: 16.0),
                              child: TagTeamCircleAvatar(
                                radius: 15,
                                onErrorReplacement: CircleAvatar(
                                    backgroundColor: Theme.of(context).accentColor,
                                    child: Icon(
                                      Icons.settings,
                                      color: Colors.white,
                                    )),
                                url: data.currentTeam!.imageLink ?? '',
                              ),
                            )),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
