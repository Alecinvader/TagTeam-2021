import 'package:flutter/material.dart';
import 'package:tagteamprod/models/user.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/team/channels/channel_api.dart';
import 'package:tagteamprod/ui/core/tagteam_circleavatar.dart';
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
      appBar: AppBar(
        centerTitle: true,
        title: Text('Settings'),
        elevation: 0,
        actions: [TextButton(onPressed: () {}, child: Text('Save'))],
      ),
      body: SafeArea(
        child: Container(
            child: Column(
          children: [
            SimpleFutureBuilder<void>(
              builder: (BuildContext context, data) {
                return ListTile(
                  title: Text('Notifications'),
                  trailing: Checkbox(
                    onChanged: (bool? value) async {
                      setState(() {
                        notifSettings = !notifSettings;
                      });
                      await ChannelApi().toggleNotifications(widget.channelId, SnackbarErrorHandler(context));
                    },
                    value: notifSettings,
                  ),
                );
              },
              future: channelFuture,
            ),
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
