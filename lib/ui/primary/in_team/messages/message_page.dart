import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tagteamprod/ui/core/tagteam_constants.dart';
import '../../../../models/channel.dart';
import '../../../../models/message.dart';
import '../../../../server/errors/snackbar_error_handler.dart';
import '../../../../server/team/channels/channel_api.dart';
import 'message_bubble.dart';
import '../../../utility/core/text_field_toggler.dart';
import '../../../utility/core/helper.dart';

class SendMesssagePage extends StatefulWidget {
  final Channel channel;

  SendMesssagePage({Key? key, required this.channel}) : super(key: key);

  @override
  _SendMesssagePageState createState() => _SendMesssagePageState();
}

class _SendMesssagePageState extends State<SendMesssagePage> {
  late Stream<QuerySnapshot> messageStream;
  late Channel channel;

  List<Message> messages = [];

  String? _pendingMessage;

  @override
  void initState() {
    super.initState();
    channel = widget.channel;
    messageStream = FirebaseFirestore.instance
        .doc('channels/${channel.firebaseId}')
        .collection('messages')
        .orderBy('createdAt')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(channel.name!),
      ),
      body: TextFieldToggler(
        child: StreamBuilder<QuerySnapshot>(
          stream: messageStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              convertSnapshotsIntoMessages(snapshot.data?.docs ?? []);
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Could not subscribe to messages'),
              );
            }

            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                      child: ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            return MessageBubble(
                                isInGroup: getIsInGroup(index),
                                showsMessageDate: getIsMessageFirstOfDay(index),
                                isFirstOfGroup: getIsMessageFirstInGroup(index),
                                isLastOfGroup: getIsMessageLastInGroup(index),
                                message: messages[index]);
                          })),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: kLightBackgroundColor,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (String value) {
                                _pendingMessage = value;
                              },
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                                  focusedBorder: InputBorder.none),
                            ),
                          ),
                          TextButton(
                              onPressed: () async {
                                if (_pendingMessage != null && _pendingMessage!.isNotEmpty) {
                                  await ChannelApi().sendMessage(
                                      110,
                                      widget.channel.teamId!,
                                      Message(message: _pendingMessage!.trim(), messageType: MessageType.text),
                                      SnackbarErrorHandler(context, overrideErrorMessage: 'Failed to send message'));
                                }
                              },
                              child: Text(
                                'Send',
                                style: TextStyle(color: Theme.of(context).accentColor),
                              ))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void convertSnapshotsIntoMessages(List<QueryDocumentSnapshot> list) {
    List<Message> tempMessages = [];

    tempMessages = List.generate(list.length, (index) => Message.fromJson(list[index].data() as Map<String, dynamic>));
    tempMessages = List<Message>.of(tempMessages.reversed);

    messages = tempMessages;
  }

  bool getIsMessageFirstOfDay(int index) {
    if (index == messages.length - 1) {
      return true;
    } else if (messages.length == 1) {
      return true;
    } else if (index < messages.length - 2) {
      if (index > 1 && !messages[index - 1].createdAt!.isSameDate(messages[index].createdAt!)) {
        return true;
      }
    }
    return false;
  }

  bool getIsMessageFirstInGroup(int index) {
    if (index == messages.length - 1) {
      return true;
    } else if (messages.length == 1) {
      return true;
    } else if (index == 0) {
      return false;
    } else if (messages[index].senderId == messages[index + 1].senderId &&
        messages[index].senderId != messages[index - 1].senderId) {
      return true;
    }

    return false;
  }

  bool getIsInGroup(int index) {
    if (messages.length == 1) {
      return false;
    } else if (index == 0 && messages[index + 1].senderId == messages[index].senderId) {
      return true;
    } else if (index == messages.length - 1 && messages[index - 1].senderId == messages[index].senderId) {
      return true;
    } else if (messages[index + 1].senderId == messages[index].senderId) {
      return true;
    } else if (messages[index - 1].senderId == messages[index].senderId) {
      return true;
    }

    return false;
  }

  bool getIsMessageLastInGroup(int index) {
    if (getIsInGroup(index) == false) {
      return false;
    } else if (index == 0) {
      return true;
    } else if (messages[index - 1].senderId != messages[index].senderId) {
      return true;
    }

    return false;
  }
}
