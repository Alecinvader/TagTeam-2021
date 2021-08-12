import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagteamprod/models/provider/team_auth_notifier.dart';
import 'package:tagteamprod/models/user.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/team/channels/channel_api.dart';

import 'package:tagteamprod/ui/core/tagteam_constants.dart';
import 'package:tagteamprod/ui/utility/core/better_future_builder.dart';

class ChannelSettingsPage extends StatefulWidget {
  final int channelId;

  ChannelSettingsPage({Key? key, required this.channelId}) : super(key: key);

  @override
  _ChannelSettingsPageState createState() => _ChannelSettingsPageState();
}

class _ChannelSettingsPageState extends State<ChannelSettingsPage> {
  late Future<void> channelFuture;

  bool notifSettings = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    channelFuture = getChannelSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Settings'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Messages'),
            ),
            SimpleFutureBuilder<void>(
              builder: (BuildContext context, data) {
                return Container(
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                  child: ListTile(
                    onTap: () async {
                      setState(() {
                        notifSettings = !notifSettings;
                      });
                      await ChannelApi().toggleNotifications(
                          widget.channelId,
                          SnackbarErrorHandler(context, onErrorHandler: () {
                            setState(() {
                              notifSettings = !notifSettings;
                            });
                          }));
                    },
                    title: Text('Notifications'),
                    trailing: Switch.adaptive(
                      onChanged: (bool? value) async {
                        setState(() {
                          notifSettings = !notifSettings;
                        });
                        await ChannelApi().toggleNotifications(
                            widget.channelId,
                            SnackbarErrorHandler(context, onErrorHandler: () {
                              setState(() {
                                notifSettings = !notifSettings;
                              });
                            }));
                      },
                      value: notifSettings,
                    ),
                  ),
                );
              },
              future: channelFuture,
            ),
            SizedBox(
              height: 40,
            ),
            Consumer<TeamAuthNotifier>(builder: (context, data, _) {
              return data.isAdmin
                  ? GestureDetector(
                      onTap: () async {
                        var count = 0;
                        Navigator.popUntil(context, (route) {
                          return count++ == 2;
                        });
                        await ChannelApi().removeChannel(widget.channelId, SnackbarErrorHandler(context));
                      },
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'DELETE CHANNEL',
                              style: TextStyle(fontSize: 16.0, color: Colors.red, fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                      ),
                    )
                  : SizedBox();
            }),
          ],
        )),
      ),
    );
  }

  Future<void> getChannelSettings() async {
    bool notifications = await ChannelApi().checkNotificationSettings(widget.channelId, SnackbarErrorHandler(context));

    setState(() {
      notifSettings = notifications;
    });
  }
}

// SimpleFutureBuilder(
// builder: (context, List<User>? data) {
// return Column(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: [
//     Padding(
//       padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 8.0),
//       child: Text(
//         'Users',
//         style: TextStyle(fontWeight: FontWeight.w500),
//       ),
//     ),
//     Container(
//       decoration: BoxDecoration(color: kLightBackgroundColor),
//       child: ListTile(
//         title: Text('Users'),
//         leading: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.group_outlined,
//               size: 30,
//               color: Colors.white,
//             ),
//           ],
//         ),
//         trailing: IconButton(
//           icon: Icon(
//             Icons.arrow_forward_ios,
//             color: Colors.white70,
//             size: 15,
//           ),
//           onPressed: () {},
//         ),
//       ),
//     ),
//     Expanded(
//         child: ListView.builder(
//       itemBuilder: (context, index) {
//         User currentUser = data![index];

//         return Container(
//           decoration: BoxDecoration(color: kLightBackgroundColor),
//           child: ListTile(
//             title: Text(currentUser.displayName ?? 'Unknown'),
//             leading: TagTeamCircleAvatar(
//               radius: 20,
//               url: currentUser.profilePicture ?? '',
//             ),
//             trailing: IconButton(
//                 onPressed: () async {
//                   await ChannelApi().removeUserFromChannel(
//                       currentUser.uid!, widget.channelId, SnackbarErrorHandler(context));
//                 },
//                 icon: Icon(
//                   Icons.more_vert,
//                   color: Colors.white,
//                 )),
//           ),
//         );
//       },
//       itemCount: data!.length,
//     )),
//   ],
// );
//   },
//   future: channelUsersFuture,
// ),
