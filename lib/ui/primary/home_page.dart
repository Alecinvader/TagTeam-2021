import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tagteamprod/server/user/user_api.dart';
import 'package:tagteamprod/ui/core/tagteam_drawer.dart';
import '../../models/tagteam.dart';
import '../../server/errors/snackbar_error_handler.dart';
import '../../server/team/team_api.dart';
import 'home_widgets/home_team_tile.dart';
import '../utility/core/better_future_builder.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<TagTeam>> future;

  @override
  void initState() {
    super.initState();
    future = TeamApi().getAllTeams(SnackbarErrorHandler(context));
    // future = Future.value([]);
    setupMessaging(context);

    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) {
      print('listened');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuDrawer(),
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text('Home'),
        ),
      ),
      body: SimpleFutureBuilder(
        builder: (BuildContext context, List<TagTeam>? data) {
          if (data?.isEmpty ?? [].isEmpty) {
            return Center(
              child: Text('You are not a part of any teams.'),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                Flexible(
                    child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      future = TeamApi().getAllTeams(SnackbarErrorHandler(context));
                    });
                  },
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return MiniDashboardTile(team: data![index]);
                    },
                    itemCount: data?.length ?? 0,
                  ),
                ))
              ],
            ),
          );
        },
        future: future,
      ),
    );
  }

  Future<void> setupMessaging(BuildContext context) async {
    final NotificationSettings hasPermission = await FirebaseMessaging.instance.requestPermission();
    
    

    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      await UserApi().updateFCMToken(token, FirebaseAuth.instance.currentUser!.uid, SnackbarErrorHandler(context));
    }

    print(token);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('received message');
    });

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    // await NotificationHandler(context, initialMessage).handleIncomingMessage();
    // print(initialMessage);
    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    // s

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('hello');

      // new NotificationHandler(context, initialMessage).handleIncomingMessage();
    });
  }
}
