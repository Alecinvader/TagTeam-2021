import 'package:flutter/material.dart';
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
                  child: GestureDetector(
                    onTap: () {
                      // final teamId = Provider.of<TeamAuth>(context, listen: false).team.id;
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => TeamOverview(
                      //               teamId: teamId,
                      //             )));
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Hero(
                          tag: 'appbar-icon',
                          child: Padding(
                              padding: EdgeInsets.only(right: 16.0, left: 16.0),
                              child: CircleAvatar(
                                backgroundColor: Theme.of(context).accentColor,
                                radius: 15.0,
                                child: Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                ),
                              )
                              // : CircleAvatar(
                              //     backgroundColor: Theme.of(context).accentColor,
                              //     radius: 15.0,
                              //     backgroundImage: Image.network(
                              //       data.team.imagePath,
                              //       fit: BoxFit.fill,
                              //       errorBuilder: (context, object, stacktrace) {
                              //         return Icon(
                              //           Icons.settings,
                              //           color: Colors.white,
                              //         );
                              //       },
                              //     ).image)

                              )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
