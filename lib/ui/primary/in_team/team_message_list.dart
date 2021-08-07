import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagteamprod/models/provider/team_auth_notifier.dart';
import 'package:tagteamprod/ui/primary/channels/create_single_channel.dart';
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

  List<Channel> sqlDataChannels = [];

  @override
  void initState() {
    super.initState();

    channelFuture = fetchChannels().then((value) {
      setState(() {
        sqlDataChannels = value;
      });
      if (firebaseUniques.isNotEmpty) {
        setState(() {
          stream1 = FirebaseFirestore.instance
              .collection('channels')
              .where(FieldPath.documentId, whereIn: firebaseUniques)
              .snapshots();
        });
      }

      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Consumer<TeamAuthNotifier>(builder: (context, data, _) {
        if (data.authType == TeamAuthType.owner || data.authType == TeamAuthType.manager) {
          return FloatingActionButton(
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
                    if (snapshot.hasData) {
                      convertSnapshotIntoChannels(snapshot.data?.docs ?? []);

                      return Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
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
                          },
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              Channel currentChannel = channels[index];

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: MessagePageTile(channel: currentChannel),
                              );
                            },
                            itemCount: channels.length,
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
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
}
