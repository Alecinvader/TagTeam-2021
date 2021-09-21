import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagteamprod/models/provider/team_auth_notifier.dart';
import 'package:tagteamprod/models/user.dart';
import 'package:tagteamprod/server/team/team_api.dart';
import 'package:tagteamprod/server/user/user_api.dart';
import 'package:tagteamprod/ui/primary/channels/create_single_channel.dart';
import 'package:tagteamprod/ui/utility/notifications/notification_handler.dart';
import '../../../models/channel.dart';
import '../../../models/message.dart';
import '../../../server/errors/snackbar_error_handler.dart';
import '../../../server/team/channels/channel_api.dart';
import '../../core/tagteam_appbar.dart';
import '../../core/tagteam_drawer.dart';
import 'messages/message_tile.dart';

class TeamMessageList extends StatefulWidget {
  final int teamId;

  const TeamMessageList({Key? key, required this.teamId}) : super(key: key);

  @override
  _TeamMessageListState createState() => _TeamMessageListState();
}

class _TeamMessageListState extends State<TeamMessageList> {
  late Future<List<Channel>> channelFuture;
  Stream<QuerySnapshot>? stream1;
  List<String> firebaseUniques = [];

  List<Channel> channels = [];

  bool futureCompleted = false;

  List<Channel> sqlDataChannels = [];

  bool blockedUsersFetched = false;

  SharedPreferences? _prefs;

  late Future<void> pendingJoinRequests;

  int _totalPendingRequests = 0;

  @override
  void initState() {
    super.initState();

    pendingJoinRequests = getPendingJoinRequests(widget.teamId);

    SharedPreferences.getInstance().then((value) {
      setState(() {
        _prefs = value;
      });
    });

    UserApi().getBlockedUsers(SnackbarErrorHandler(context, showSnackBar: true)).then((value) {
      Provider.of<TeamAuthNotifier>(context, listen: false).blockedUsers = value;

      setState(() {
        blockedUsersFetched = true;
      });
    });

    channelFuture = fetchChannels().then((value) {
      if (firebaseUniques.isNotEmpty) {
        setState(() {
          stream1 = FirebaseFirestore.instance
              .collection('channels')
              .where(FieldPath.documentId, whereIn: firebaseUniques)
              .snapshots();
        });
      }

      setState(() {
        sqlDataChannels = value;
        futureCompleted = true;
      });

      return value;
    }).catchError((error) {
      setState(() {
        futureCompleted = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Consumer<TeamAuthNotifier>(builder: (context, data, _) {
        if (data.authType == TeamAuthType.owner || data.authType == TeamAuthType.manager) {
          return FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateSingleChannel(
                            teamId: widget.teamId,
                          )));
            },
          );
        }
        return SizedBox();
      }),
      drawer: MenuDrawer(),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              TagTeamAppBar(onTap: () {}, title: 'Messages'),
              StreamBuilder<QuerySnapshot>(
                  stream: stream1,
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (futureCompleted == true && sqlDataChannels.isEmpty) {
                      return SizedBox();
                    }

                    if (snapshot.hasData && _prefs != null) {
                      convertSnapshotIntoChannels(snapshot.data?.docs ?? []);

                      if (channels.length == 0) {
                        return Expanded(
                          child: Center(
                            child: TextButton.icon(
                                onPressed: refresh,
                                icon: Icon(
                                  Icons.refresh,
                                  color: Theme.of(context).accentColor,
                                ),
                                label: Text('Refresh',
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                    ))),
                          ),
                        );
                      }

                      return Expanded(
                        child: RefreshIndicator(
                          onRefresh: refresh,
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              Channel currentChannel = channels[index];

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: MessagePageTile(
                                  newestSenderId: currentChannel.mostRecentMessage?.senderId ?? '',
                                  channel: currentChannel,
                                  prefs: _prefs!,
                                  newestDate: currentChannel.mostRecentMessage?.createdAt ?? DateTime(2000),
                                ),
                              );
                            },
                            itemCount: channels.length,
                          ),
                        ),
                      );
                    } else if (futureCompleted == false) {
                      return Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      );
                    } else {
                      return Expanded(
                        child: Center(
                            child: TextButton.icon(
                                onPressed: refresh,
                                icon: Icon(
                                  Icons.refresh,
                                  color: Theme.of(context).accentColor,
                                ),
                                label: Text('Refresh',
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                    )))),
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> refresh() async {
    await fetchChannels().then((value) {
      setState(() {
        sqlDataChannels = value;
        stream1 = FirebaseFirestore.instance
            .collection('channels')
            .where(FieldPath.documentId, whereIn: firebaseUniques)
            .snapshots();
      });

      return value;
    });

    UserApi().getBlockedUsers(SnackbarErrorHandler(context, showSnackBar: true)).then((value) {
      Provider.of<TeamAuthNotifier>(context, listen: false).blockedUsers = value;
    });
  }

  void convertSnapshotIntoChannels(List<QueryDocumentSnapshot> list) {
    List<Channel> tempChannels = List.generate(list.length, (index) {
      return Channel.fromJson({...list[index].data() as Map<String, dynamic>, "firebaseID": list[index].id});
    });

    // Match up initial channel ID's with Firebase collection data
    // Need to hard refresh in order to setup new incoming channels
    for (int i = 0; i < sqlDataChannels.length; i++) {
      tempChannels.forEach((element) {
        if (element.firebaseId == sqlDataChannels[i].firebaseId) {
          element.id = sqlDataChannels[i].id;
        }
      });
    }

    tempChannels.sort((a, b) {
      DateTime firstMessage = a.mostRecentMessage?.createdAt ?? DateTime(2000);
      DateTime secondMessage = b.mostRecentMessage?.createdAt ?? DateTime(2000);

      return secondMessage.compareTo(firstMessage);
    });

    channels = tempChannels;
  }

  Future<List<Channel>> fetchChannels() async {
    List<Channel> temp = [];

    firebaseUniques = [];

    temp = await ChannelApi().getChannelsForTeam(
      widget.teamId,
      SnackbarErrorHandler(context),
    );

    temp.forEach((element) {
      if (element.firebaseId != null) {
        firebaseUniques.add(element.firebaseId!);
      }
    });

    return temp;
  }

  Future<void> getPendingJoinRequests(int teamId) async {
    TeamAuthNotifier notifier = Provider.of<TeamAuthNotifier>(context, listen: false);
    if (notifier.isAdmin) {
      List<User> users = await TeamApi().allJoinRequests(teamId, SnackbarErrorHandler(context));
      if (users.length > 0) {
        notifier.updatePendingRequets(users.length);
      }
    } else {
      return;
    }
  }
}
