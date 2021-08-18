import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagteamprod/ui/create_team/team_create_start.dart';
import 'package:tagteamprod/ui/primary/search_team.dart';
import 'package:tagteamprod/ui/user/account_info.dart';
import '../login/sign_in.dart';
import '../primary/home_page.dart';

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.red, size: 30.0, opacity: 1),
      ),
      child: Drawer(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          color: Theme.of(context).primaryColor,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(0),
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 16.0, bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(width: 40, child: Image.asset('assets/images/TagTeamLogo.png')),
                            const SizedBox(width: 8.0),
                            Text(
                              'TagTeam',
                              style: TextStyle(
                                  color: Theme.of(context).accentColor, fontSize: 18.0, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.white,
                      ),
                      ListTile(
                        onTap: () async {
                          await Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false);
                        },
                        leading: Icon(
                          Icons.dashboard,
                          color: Colors.white,
                        ),
                        title: Text('Teams', style: TextStyle(fontSize: 16.0)),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TeamBasicDetails()));
                        },
                        leading: Icon(
                          Icons.add_circle_outline_outlined,
                          color: Colors.white,
                        ),
                        title: Text('Create Team', style: TextStyle(fontSize: 16.0)),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchForTeam(),
                              ));
                        },
                        leading: Icon(
                          Icons.people_outline,
                          color: Colors.white,
                        ),
                        title: Text('Join Team', style: TextStyle(fontSize: 16.0)),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AccountInfo()));
                        },
                        leading: Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                        ),
                        title: Text('Account', style: TextStyle(fontSize: 16.0)),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ListTile(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      SharedPreferences prefs = await SharedPreferences.getInstance();

                      if (prefs.containsKey('userkey')) {
                        await prefs.remove('userkey');
                        await prefs.remove('username');
                      }

                      // await GoogleSignIn().signOut();
                      await Navigator.pushAndRemoveUntil(
                          context, MaterialPageRoute(builder: (context) => SignIn()), (route) => false);
                    },
                    leading: Icon(
                      Icons.exit_to_app_outlined,
                      color: Colors.white,
                    ),
                    title: Text('Sign Out', style: TextStyle(fontSize: 16.0)),
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
