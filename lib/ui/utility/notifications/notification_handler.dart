import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:tagteamprod/models/channel.dart';
import 'package:tagteamprod/models/provider/team_auth_notifier.dart';
import 'package:tagteamprod/models/tagteam.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/responses/server_response.dart';
import 'package:tagteamprod/server/team/channels/channel_api.dart';
import 'package:tagteamprod/server/team/team_api.dart';
import 'package:tagteamprod/ui/login/splash_page.dart';
import 'package:tagteamprod/ui/primary/home_page.dart';
import 'package:tagteamprod/ui/primary/in_team/messages/message_page.dart';
import 'package:tagteamprod/ui/primary/in_team/team_info.dart';
import 'package:tagteamprod/ui/primary/in_team/team_message_list.dart';

class NotificationHandler {
  NotificationHandler();

  Future<void> tryNavigateToMessage(int teamId, String firebaseId) async {
    try {
      TagTeam? currentTeam = Provider.of<TeamAuthNotifier>(Get.context!, listen: false).currentTeam;
      List<TagTeam> teams = [];

      List<Channel> channels = [];

      // Make sure the person is actually in the team

      // await Navigator.of(context)
      //     .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false);

      // Get all the channels and then get the one where it matches

      // Do this if the current locally saved team is already active and check it against claims
      if (currentTeam != null && (currentTeam.teamId == teamId)) {
        Get.to(() => Scaffold(
              body: SplashPage(),
            ));

        IdTokenResult result = await FirebaseAuth.instance.currentUser!.getIdTokenResult();

        channels = await ChannelApi().getChannelsForTeam(
            teamId,
            SnackbarErrorHandler(Get.context!, onErrorHandler: () {
              throw "Could not get channles";
            }));

        Channel? currentChannel;
        channels.forEach((element) {
          if (element.firebaseId == firebaseId) {
            currentChannel = element;
          }
        });

        if (result.claims!['team'] == currentTeam.teamId) {
          await Get.offAll(() => SendMesssagePage(
                channel: currentChannel!,
                popToTeam: true,
              ));
        }
        // Otherwise do the typical of getting all the teams and matching it up while refreshing the token to get new claims
      } else {
        Get.to(() => Scaffold(
              body: SplashPage(
                bottomWidget: Text("Changing teams..."),
              ),
            ));

        teams = await TeamApi().getAllTeams(SnackbarErrorHandler(Get.context!, onErrorHandler: () {
          throw "Could not get all teams";
        }));
        if (teams.isEmpty) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
            content: Text("Team does not exist"),
          ));
          Navigator.pop(Get.context!);
        }
        teams.forEach((element) {
          if (element.teamId == teamId) {
            currentTeam = element;
          }
        });
        if (currentTeam != null) {
          final ServerResponse role = await TeamApi().setActiveTeam(
              teamId,
              SnackbarErrorHandler(Get.context!, onErrorHandler: () {
                throw "could not set team active";
              }));

          await FirebaseAuth.instance.currentUser!.getIdToken(true);

          channels = await ChannelApi().getChannelsForTeam(
              teamId,
              SnackbarErrorHandler(Get.context!, onErrorHandler: () {
                throw "could not get channels";
              }));

          Channel? currentChannel;
          channels.forEach((element) {
            if (element.firebaseId == firebaseId) {
              currentChannel = element;
            }
          });

          Provider.of<TeamAuthNotifier>(Get.context!, listen: false).setActiveTeam(currentTeam!, role.message!);

          Get.offAll(() => SendMesssagePage(
                popToTeam: true,
                channel: currentChannel!,
              ));
        }
      }
    } catch (error) {
      // await Navigator.of(context)
      //     .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false);
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text(error.toString())));
      Get.offAll(() => HomePage());
      throw error;
    }
  }

  Future<void> tryGoToTeamRequest(int teamId) async {
    TeamAuthNotifier teamAuthNotifier = Provider.of<TeamAuthNotifier>(Get.context!, listen: false);

    try {
      Get.to(Scaffold(body: SplashPage()));

      if (teamAuthNotifier.currentTeam?.teamId == teamId) {
        Get.offAll(TeamMessageList(teamId: teamId));
        Get.to(() => TeamInfo());
      } else {
        final ServerResponse role = await TeamApi().setActiveTeam(
            teamId,
            SnackbarErrorHandler(Get.context!, onErrorHandler: () {
              throw "Could not set team as active";
            }));

        await FirebaseAuth.instance.currentUser!.getIdToken(true);

        List<TagTeam> teams = await TeamApi().getAllTeams(SnackbarErrorHandler(Get.context!, onErrorHandler: () {
          throw "Could not get teams for user";
        }));

        TagTeam? selectedTeam;
        teams.forEach((element) {
          if (element.teamId == teamId) {
            selectedTeam = element;
          }
        });

        if (selectedTeam == null) throw "Team does not exist or failed to fetch";

        teamAuthNotifier.setActiveTeam(selectedTeam!, role.message!);

        Get.offAll(TeamMessageList(teamId: teamId));
        Get.to(() => TeamInfo());
      }
    } catch (error) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text(error.toString())));
      Get.to(() => HomePage());
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
