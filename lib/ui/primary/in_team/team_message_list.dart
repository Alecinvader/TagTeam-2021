import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tagteamprod/models/channel.dart';
import 'package:tagteamprod/models/message.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/team/channels/channel_api.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    channelFuture = fetchChannels().then((value) {
      if (firebaseUniques.isNotEmpty) {
        print('did this');
        setState(() {
          stream1 = FirebaseFirestore.instance
              .collection('channels')
              .where(FieldPath.documentId, whereIn: firebaseUniques)
              .snapshots();
        });
      }
      return value;
    });

    // Stream stream1 = FirebaseFirestore.instance.collection('channels').where('')
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print('was pressed');
          await ChannelApi().sendMessage(
              105,
              Message(message: 'Hello this is an epic test message!', messageType: MessageType.text),
              SnackbarErrorHandler(context));
        },
      ),
      drawer: Drawer(),
      appBar: AppBar(
        title: Text('Messages'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                  stream: stream1,
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      var temp = snapshot.data!.docs;

                      return Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            Map<String, dynamic> data = temp[index].data() as Map<String, dynamic>;

                            Channel currentChannel = Channel.fromJson(data);

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: MessagePageTile(channel: currentChannel),
                            );
                          },
                          itemCount: temp.length,
                        ),
                      );
                    } else
                      return Text('dont have data');
                  }),
            ],
          ),
        ),
      ),
    );
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
