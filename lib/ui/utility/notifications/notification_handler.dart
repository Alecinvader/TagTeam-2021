import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagteamprod/models/channel.dart';
import 'package:tagteamprod/models/chat_notification.dart';
import 'package:tagteamprod/models/provider/team_auth_notifier.dart';
import 'package:tagteamprod/models/tagteam.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/responses/server_response.dart';
import 'package:tagteamprod/server/team/channels/channel_api.dart';
import 'package:tagteamprod/server/team/team_api.dart';
import 'package:tagteamprod/server/user/user_api.dart';
import 'package:tagteamprod/ui/primary/home_page.dart';
import 'package:tagteamprod/ui/primary/in_team/messages/message_page.dart';

class NotificationHandler {
  BuildContext context;

  NotificationHandler(this.context);

  Future<void> tryNavigateToMessage(int teamId, String firebaseId) async {
    List<TagTeam> teams = await TeamApi().getAllTeams(SnackbarErrorHandler(context));
    List<Channel> channels = [];

    // Make sure the person is actually in the team
    if (teams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Team does not exist")));
    }
    // await Navigator.of(context)
    // .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false);

    // Get all the channels and then get the one where it matches
    channels = await ChannelApi().getChannelsForTeam(teamId, SnackbarErrorHandler(context));
    TagTeam? currentTeam;
    teams.forEach((element) {
      if (element.teamId == teamId) {
        currentTeam = element;
      }
    });

    Channel? currentChannel;
    channels.forEach((element) {
      if (element.firebaseId == firebaseId) {
        currentChannel = element;
      }
    });

    if (currentTeam != null && currentChannel != null) {
      final ServerResponse role = await TeamApi().setActiveTeam(teamId, SnackbarErrorHandler(context));

      await FirebaseAuth.instance.currentUser!.getIdToken(true);

      Provider.of<TeamAuthNotifier>(context, listen: false).setActiveTeam(currentTeam!, role.message!);

      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => SendMesssagePage(channel: currentChannel!)));
    }
  }

  // Future<void> setupMessaging(BuildContext context) async {
  //   final NotificationSettings hasPermission = await FirebaseMessaging.instance.requestPermission();

  //   String? token = await FirebaseMessaging.instance.getToken();

  //   if (token != null) {
  //     await UserApi().updateFCMToken(token, FirebaseAuth.instance.currentUser!.uid, SnackbarErrorHandler(context));
  //   }

  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
  //     ChatNotification? chatNotification;
  //     if (message.data['type'] == "chat") {
  //       chatNotification = ChatNotification.fromJson(message.data);

  //       showToast(message.notification!.title!, message.notification!.body!, chatNotification.firebaseId!,
  //           chatNotification.teamId!);
  //     }
  //   });

  //   RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  //   // await NotificationHandler(context, initialMessage).handleIncomingMessage();
  //   // print(initialMessage);
  //   // If the message also contains a data property with a "type" of "chat",
  //   // navigate to a chat screen
  //   // s

  //   // Also handle any interaction when the app is in the background via a
  //   // Stream listener
  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
  //     ChatNotification? chatNotification;

  //     if (message.data['type'] == "chat") {
  //       chatNotification = ChatNotification.fromJson(message.data);

  //       await NotificationHandler(context)
  //           .tryNavigateToMessage(chatNotification.teamId ?? 0, chatNotification.firebaseId ?? '');
  //     }
  //   });
  // }
}