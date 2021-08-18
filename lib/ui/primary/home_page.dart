import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tagteamprod/server/user/user_api.dart';
import 'package:tagteamprod/ui/core/tagteam_constants.dart';
import 'package:tagteamprod/ui/core/tagteam_drawer.dart';
import 'package:tagteamprod/ui/primary/search_team.dart';
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
    initDynamicLinks();
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) {
      print('listened');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuDrawer(),
      appBar: AppBar(
        centerTitle: true,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('You are not a part of any teams'),
                  TextButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SearchForTeam()));
                      },
                      icon: Icon(
                        Icons.search_outlined,
                        color: Theme.of(context).accentColor,
                      ),
                      label: Text(
                        'Find Team',
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ))
                ],
              ),
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

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;

      print(deepLink);

      // if (deepLink != null) {
      //   Navigator.pushNamed(context, deepLink.path);
      // }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    print(deepLink);

    if (deepLink != null) {
      // Navigator.pushNamed(context, deepLink.path);
    }
  }

  Future<void> setupMessaging(BuildContext context) async {
    final NotificationSettings hasPermission = await FirebaseMessaging.instance.requestPermission();

    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      await UserApi().updateFCMToken(token, FirebaseAuth.instance.currentUser!.uid, SnackbarErrorHandler(context));
    }

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
