import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:tagteamprod/models/chat_notification.dart';
import 'package:tagteamprod/models/provider/team_auth_notifier.dart';
import 'package:tagteamprod/server/user/user_api.dart';
import 'package:tagteamprod/ui/core/tagteam_circleavatar.dart';
import 'package:tagteamprod/ui/core/tagteam_constants.dart';
import 'package:tagteamprod/ui/core/tagteam_drawer.dart';
import 'package:tagteamprod/ui/primary/search_team.dart';
import 'package:tagteamprod/ui/utility/notifications/notification_handler.dart';

import '../../models/tagteam.dart';
import '../../server/errors/snackbar_error_handler.dart';
import '../../server/team/team_api.dart';
import '../utility/core/better_future_builder.dart';
import 'home_widgets/home_team_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<TagTeam>> future;

  late FToast fToast;

  @override
  void initState() {
    super.initState();
    future = TeamApi().getAllTeams(SnackbarErrorHandler(context));
    fToast = FToast();
    fToast.init(context);
    setupMessaging(context);
    initDynamicLinks();
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showRequestNotif('Request to join', 'Alec has requested to join your team', 57);
        },
      ),
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

      String inviteCode = '';

      if (deepLink.toString().contains('code')) {
        inviteCode = deepLink.toString().split('=')[1];
        inviteCode = inviteCode.substring(0, inviteCode.length - 1);
      }

      if (inviteCode.isNotEmpty) {
        await showJoinDialog(inviteCode);
      }
    }, onError: (OnLinkErrorException e) async {
      print(e.message);
    });

    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    String inviteCode = '';

    if (deepLink.toString().contains('code')) {
      inviteCode = deepLink.toString().split('=')[1];
      inviteCode = inviteCode.substring(0, inviteCode.length - 1);
    }

    if (inviteCode.isNotEmpty) {
      await showJoinDialog(inviteCode);
    }
  }

  Future<void> setupMessaging(BuildContext context) async {
    final NotificationSettings hasPermission = await FirebaseMessaging.instance.requestPermission();

    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      await UserApi().updateFCMToken(token, FirebaseAuth.instance.currentUser!.uid, SnackbarErrorHandler(context));
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      ChatNotification? chatNotification;
      if (message.data['type'] == "chat") {
        chatNotification = ChatNotification.fromJson(message.data);
        if (Provider.of<TeamAuthNotifier>(Get.context ?? this.context, listen: false).activeChannelId !=
            chatNotification.firebaseId) {
          showMessageNotif(message.notification!.title!, message.notification!.body!, chatNotification.firebaseId!,
              chatNotification.teamId!);
        }
      } else if (message.data['type'] == "request") {
        int? teamId = message.data['teamID'];

        if (teamId != null) {
          showRequestNotif(message.notification!.title!, message.notification!.body!, teamId);
        }
      }
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
      ChatNotification? chatNotification;

      if (message.data['type'] == "chat") {
        chatNotification = ChatNotification.fromJson(message.data);
        if (Provider.of<TeamAuthNotifier>(context, listen: false).activeChannelId != chatNotification.firebaseId) {
          await NotificationHandler(context)
              .tryNavigateToMessage(chatNotification.teamId ?? 0, chatNotification.firebaseId ?? '');
        }
      }
    });
  }

  void showMessageNotif(String title, String body, String firebaseId, int teamId) {
    BuildContext context = Get.context ?? this.context;

    Get.snackbar(title, body,
        backgroundColor: Color(0xFF293C4D),
        messageText: Text(
          body,
          maxLines: 2,
        ), onTap: (object) {
      NotificationHandler(context).tryNavigateToMessage(teamId, firebaseId);
    });

    // Widget toast = GestureDetector(
    //   onVerticalDragEnd: (DragEndDetails details) {
    //     if (details.primaryVelocity!.abs() > 100) {
    //       fToast.removeQueuedCustomToasts();
    //     }
    //   },
    //   onTap: () async {
    //     fToast.removeQueuedCustomToasts();

    //     NotificationHandler(context).tryNavigateToMessage(teamId, firebaseId);
    //   },
    //   child: Stack(
    //     clipBehavior: Clip.none,
    //     children: [
    //       Material(
    //           borderRadius: BorderRadius.circular(8.0),
    //           elevation: 8.0,
    //           child: Container(
    //             width: double.infinity,
    //             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    //             decoration: BoxDecoration(
    //               borderRadius: BorderRadius.circular(8.0),
    //               color: Color(0xFF293C4D),
    //             ),
    //             child: Row(
    //               children: [
    //                 Column(
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: [
    //                     Text(
    //                       '$title',
    //                       style: TextStyle(color: Colors.white),
    //                     ),
    //                     Wrap(
    //                       children: [
    //                         Text(
    //                           "$body",
    //                           maxLines: 2,
    //                           style: TextStyle(color: Colors.white70),
    //                         ),
    //                       ],
    //                     ),
    //                   ],
    //                 ),
    //               ],
    //             ),
    //           )),
    //       Align(
    //         alignment: Alignment.topRight,
    //         child: Container(
    //           width: 10,
    //           height: 10,
    //           decoration: BoxDecoration(
    //             shape: BoxShape.circle,
    //             color: Theme.of(context).accentColor,
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );

    // fToast.showToast(
    //     child: toast,
    //     toastDuration: Duration(seconds: 2),
    //     positionedToastBuilder: (context, child) {
    //       return Positioned(
    //         child: child,
    //         top: 36.0,
    //         left: 16.0,
    //         right: 16.0,
    //       );
    //     });
    // Custom Toast Position
  }

  void showRequestNotif(String title, String body, int teamId) {
    BuildContext context = Get.context ?? this.context;

    Get.snackbar(title, body,
        backgroundColor: Color(0xFF293C4D),
        messageText: Text(
          body,
          maxLines: 2,
        ), onTap: (object) {
      NotificationHandler(context).tryGoToTeamRequest(teamId);
    });
  }

  Future<void> showJoinDialog(String inviteCode) async {
    TagTeam team = await TeamApi()
        .searchByInviteCode(inviteCode, SnackbarErrorHandler(context, overrideErrorMessage: 'Team no longer exists'));

    await showDialog(
        context: Get.context ?? context,
        builder: (context2) {
          return SimpleDialog(
            backgroundColor: kLightBackgroundColor,
            title: Text('Hurray! You\'re invited to ${team.name}'),
            children: [
              ListTile(
                leading: TagTeamCircleAvatar(url: team.imageLink ?? '', radius: 20),
                title: Text(team.name!),
                trailing: TextButton(
                    onPressed: () async {
                      Navigator.pop(context2);
                      await TeamApi().requestToJoinTeam(team.teamId ?? 0, SnackbarErrorHandler(context));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Request sent'),
                        behavior: SnackBarBehavior.floating,
                      ));
                    },
                    child: Text(
                      'Request',
                      style: TextStyle(color: Theme.of(context).accentColor),
                    )),
              ),
            ],
          );
        });
  }
}
