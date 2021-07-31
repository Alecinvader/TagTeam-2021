import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tagteamprod/models/channel.dart';
import 'package:tagteamprod/models/message.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/team/channels/channel_api.dart';
import 'package:tagteamprod/ui/core/tagteam_appbar.dart';
import 'package:tagteamprod/ui/core/tagteam_drawer.dart';
import 'package:tagteamprod/ui/primary/in_team/messages/message_tile.dart';

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

  @override
  void initState() {
    super.initState();

    channelFuture = fetchChannels().then((value) {
      setState(() {
        channels = value;
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ChannelApi().sendMessage(
              110,
              Message(message: 'Hello this is an epic test message!', messageType: MessageType.text),
              SnackbarErrorHandler(context));
        },
      ),
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

    tempChannels.forEach((Channel element) {
      Channel? matchingIdChannel = channels.firstWhere((element) => element.firebaseId == element.firebaseId);
      element.id = matchingIdChannel.id;
    });

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
