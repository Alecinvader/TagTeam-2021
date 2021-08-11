import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagteamprod/models/provider/team_auth_notifier.dart';
import 'package:tagteamprod/server/storage/storage_utility.dart';
import 'package:tagteamprod/ui/core/tagteam_constants.dart';
import 'package:tagteamprod/ui/primary/channels/channel_settings_page.dart';
import '../../../../models/channel.dart';
import '../../../../models/message.dart';
import '../../../../server/errors/snackbar_error_handler.dart';
import '../../../../server/team/channels/channel_api.dart';
import 'message_bubble.dart';
import '../../../utility/core/text_field_toggler.dart';
import '../../../utility/core/helper.dart';
import 'message_image_confirmation.dart';

class SendMesssagePage extends StatefulWidget {
  final Channel channel;

  SendMesssagePage({Key? key, required this.channel}) : super(key: key);

  @override
  _SendMesssagePageState createState() => _SendMesssagePageState();
}

class _SendMesssagePageState extends State<SendMesssagePage> {
  late Stream<QuerySnapshot> messageStream;
  late Channel channel;

  final TextEditingController _textFieldController = new TextEditingController();

  List<Message> messages = [];

  String? _pendingMessage;

  @override
  void initState() {
    super.initState();
    channel = widget.channel;
    ChannelApi()
        .setChannelActive(
            widget.channel.id!,
            widget.channel.teamId!,
            SnackbarErrorHandler(context, onErrorHandler: () {
              Navigator.pop(context);
            }))
        .then((value) => FirebaseAuth.instance.currentUser!.getIdToken(true));

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
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChannelSettingsPage(
                              channelId: channel.id!,
                            )));
              },
              icon: Icon(Icons.settings))
        ],
        elevation: 0.0,
        title: Text(widget.channel.name!),
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
                    child: CustomScrollView(reverse: true, slivers: [
                      SliverList(
                          delegate: SliverChildBuilderDelegate((context, index) {
                        return MessageBubble(
                            isInGroup: getIsInGroup(index),
                            showsMessageDate: getIsMessageFirstOfDay(index),
                            isFirstOfGroup: getIsMessageFirstInGroup(index),
                            isLastOfGroup: getIsMessageLastInGroup(index),
                            message: messages[index]);
                      }, childCount: messages.length)),
                    ]),
                  ),
                  Consumer<TeamAuthNotifier>(builder: (context, data, _) {
                    if (data.authType == TeamAuthType.user && channel.type == ChannelType.announcment) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: SizedBox(),
                      );
                    }

                    return Padding(
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
                                minLines: 1,
                                maxLines: 6,
                                controller: _textFieldController,
                                onChanged: (String value) {
                                  _pendingMessage = value;
                                },
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none),
                              ),
                            ),
                            IconButton(onPressed: selectAndSendImage, icon: Icon(Icons.image_outlined)),
                            TextButton(
                                onPressed: () async {
                                  if (_pendingMessage != null && _pendingMessage!.isNotEmpty) {
                                    _textFieldController.clear();

                                    await ChannelApi().sendMessage(
                                        widget.channel.id!,
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
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future selectAndSendImage() async {
    final String imagePath = await StorageUtility().getImagePath(SnackbarErrorHandler(context));

    if (imagePath.isNotEmpty) {
      await showDialog(
          context: context,
          builder: (context) => ImageDialogConfirmation(
              imagePath: imagePath,
              onChoice: (bool value) async {
                if (value) {
                  if (imagePath.isNotEmpty) {
                    //   imageRefAfterUpload =
                    //       imageRefAfterUpload.split('.').first + '' + '.' + imageRefAfterUpload.split('.')[1];

                    // print(imageRefAfterUpload);

                    

                    String endOfMessage = imagePath.split('/').last;



                    String updatedPath =  endOfMessage.split('.')[0] + '_400x400' + '.' + endOfMessage.split('.')[1];


                    print(updatedPath);
                    

                    await ChannelApi().sendMessage(
                        widget.channel.id!,
                        widget.channel.teamId!,
                        Message(
                            imagePath: 'channels/${widget.channel.firebaseId}/$updatedPath',
                            messageType: MessageType.image),
                        SnackbarErrorHandler(context, overrideErrorMessage: 'Failed to send message'));

                    String imageRefAfterUpload = await StorageUtility()
                        .uploadFile(imagePath, 'channels/${widget.channel.firebaseId}', SnackbarErrorHandler(context));
                  }
                }
              }));
    }
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
      return false;
    } else if (messages[index].senderId == messages[index - 1].senderId &&
        messages[index].senderId != messages[index + 1].senderId) {
      return true;
    }

    return false;
  }

  bool getIsInGroup(int index) {
    if (messages.length == 1) {
      return false;
    } else if (index == 0 && messages[index + 1].senderId != messages[index].senderId) {
      return false;
    } else if (index == messages.length - 1 && messages[index - 1].senderId == messages[index].senderId) {
      return true;
    } else if (index == messages.length - 1) {
      return false;
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
