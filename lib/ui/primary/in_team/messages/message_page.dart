import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbauth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagteamprod/models/provider/team_auth_notifier.dart';
import 'package:tagteamprod/models/user.dart';
import 'package:tagteamprod/server/storage/storage_utility.dart';
import 'package:tagteamprod/server/user/user_api.dart';
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
  // Stream
  late Stream<QuerySnapshot> messageStream;
  late Channel channel;

  final TextEditingController _textFieldController = new TextEditingController();

  int _pendingMessageId = 0;

  // Messages
  List<Message> messages = [];
  String? _pendingMessage;

  // Local Storage
  SharedPreferences? _preferences;

  @override
  void initState() {
    super.initState();

    // Get blocked users
    UserApi().getBlockedUsers(SnackbarErrorHandler(context)).then((value) {
      Provider.of<TeamAuthNotifier>(context, listen: false).blockedUsers = value;
      setState(() {});
    });

    // Have this ready to set exit date
    SharedPreferences.getInstance().then((SharedPreferences prefs) async {
      setState(() {
        _preferences = prefs;
      });
    });

    channel = widget.channel;

    // Set the channel as active in server
    ChannelApi()
        .setChannelActive(
            widget.channel.id!,
            widget.channel.teamId!,
            SnackbarErrorHandler(context, onErrorHandler: () {
              Navigator.pop(context);
            }))
        .then((value) => fbauth.FirebaseAuth.instance.currentUser!.getIdToken(true));

    // Grab all the snapshots
    messageStream = FirebaseFirestore.instance
        .doc('channels/${channel.firebaseId}')
        .collection('messages')
        .orderBy('createdAt')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_preferences != null) {
          await _preferences!.setString('${channel.id}', DateTime.now().toIso8601String());
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () async {
                  Channel updatedChannel = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChannelSettingsPage(
                                channel: channel,
                              )));

                  setState(() {
                    channel = updatedChannel;
                  });
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
                if (!(snapshot.data!.docs.length < messages.length))
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
                              key: Key('$index'),
                              channelId: widget.channel.firebaseId!,
                              isInGroup: getIsInGroup(index),
                              isWithin10MinutesOfNextMessage: getIsWithinTimeFrame(index),
                              showsMessageDate: getIsMessageFirstOfDay(index),
                              isFirstOfGroup: getIsMessageFirstInGroup(index),
                              isLastOfGroup: getIsMessageLastInGroup(index),
                              message: messages[index]);
                        }, childCount: messages.length)),
                      ]),
                    ),
                    Consumer<TeamAuthNotifier>(builder: (context, data, _) {
                      if (!data.isAdmin && channel.type == ChannelType.announcment) {
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
                              channel.allowImageSending == true
                                  ? IconButton(
                                      onPressed: () async {
                                        await sendMessage(true);
                                      },
                                      icon: Icon(Icons.image_outlined))
                                  : SizedBox(),
                              TextButton(
                                  onPressed: () async {
                                    if (_pendingMessage != null && _pendingMessage!.isNotEmpty) {
                                      _textFieldController.clear();
                                      await sendMessage(false);

                                      setState(() {
                                        _pendingMessage = '';
                                      });
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
      ),
    );
  }

  Future<void> sendMessage(bool isImage) async {
    if (isImage) {
      final String imagePath = await StorageUtility().getImagePath(SnackbarErrorHandler(context));

      if (imagePath.isNotEmpty) {
        await showDialog(
            context: context,
            builder: (context2) => ImageDialogConfirmation(
                imagePath: imagePath,
                onChoice: (bool value) async {
                  if (value) {
                    String tempIdLiteral = '${(_pendingMessageId + 1)}';

                    setState(() {
                      messages.insert(
                          0,
                          Message(
                              messageId: tempIdLiteral,
                              createdAt: DateTime.now(),
                              message: 'Sent an image',
                              isFileImage: true,
                              imagePath: imagePath,
                              senderPhoto: '',
                              senderDisplayName: "User's name",
                              channelId: widget.channel.id,
                              senderId: fbauth.FirebaseAuth.instance.currentUser!.uid));
                    });

                    String imageRefAfterUpload = await StorageUtility()
                        .uploadFile(imagePath, 'channels/${widget.channel.firebaseId}', SnackbarErrorHandler(context));

                    String? downloadLink =
                        await StorageUtility().getImageURL(imageRefAfterUpload, SnackbarErrorHandler(context));

                    await ChannelApi().sendMessage(
                        widget.channel.id!,
                        widget.channel.teamId!,
                        Message(imagePath: downloadLink, messageType: MessageType.image),
                        SnackbarErrorHandler(context, overrideErrorMessage: 'Failed to send message',
                            onErrorHandler: () {
                          setState(() {
                            messages.removeWhere((element) => element.messageId == tempIdLiteral);
                          });
                        }));
                  }
                }));
      }
    } else {
      String tempIdLiteral = '${(_pendingMessageId + 1)}';

      setState(() {
        messages.insert(
            0,
            Message(
                messageId: tempIdLiteral,
                createdAt: DateTime.now(),
                message: _pendingMessage!.trim(),
                senderPhoto: '',
                senderDisplayName: "User's name",
                channelId: widget.channel.id,
                senderId: fbauth.FirebaseAuth.instance.currentUser!.uid));
      });

      await ChannelApi().sendMessage(
          widget.channel.id!,
          widget.channel.teamId!,
          Message(message: _pendingMessage!.trim(), messageType: MessageType.text),
          SnackbarErrorHandler(context, overrideErrorMessage: 'Failed to send message', onErrorHandler: () {
            setState(() {
              messages.removeWhere((element) => element.messageId == tempIdLiteral);
            });
          }));
    }
  }

  // Future selectAndSendImage() async {
  //   final String imagePath = await StorageUtility().getImagePath(SnackbarErrorHandler(context));

  //   if (imagePath.isNotEmpty) {
  //     await showDialog(
  //         context: context,
  //         builder: (context2) => ImageDialogConfirmation(
  //             imagePath: imagePath,
  //             onChoice: (bool value) async {
  //               if (value) {
  //                 if (imagePath.isNotEmpty) {
  //                   String endOfMessage = imagePath.split('/').last;

  //                   String imageRefAfterUpload = await StorageUtility()
  //                       .uploadFile(imagePath, 'channels/${widget.channel.firebaseId}', SnackbarErrorHandler(context));

  //                   String? downloadLink =
  //                       await StorageUtility().getImageURL(imageRefAfterUpload, SnackbarErrorHandler(context));

  //                   String tempIdLiteral = '${(_pendingMessageId + 1)}';

  //                   setState(() {
  //                     messages.insert(
  //                         0,
  //                         Message(
  //                             messageId: tempIdLiteral,
  //                             createdAt: DateTime.now(),
  //                             message: _pendingMessage!.trim(),
  //                             senderPhoto: '',
  //                             senderDisplayName: "User's name",
  //                             channelId: widget.channel.id,
  //                             senderId: fbauth.FirebaseAuth.instance.currentUser!.uid));
  //                   });

  //                   await ChannelApi().sendMessage(
  //                       widget.channel.id!,
  //                       widget.channel.teamId!,
  //                       Message(message: _pendingMessage!.trim(), messageType: MessageType.text),
  //                       SnackbarErrorHandler(context, overrideErrorMessage: 'Failed to send message',
  //                           onErrorHandler: () {
  //                         setState(() {
  //                           messages.removeWhere((element) => element.messageId == tempIdLiteral);
  //                         });
  //                       }));
  //                 }
  //               }
  //             }));
  //   }
  // }

  void convertSnapshotsIntoMessages(List<QueryDocumentSnapshot> list) {
    List<Message> tempMessages = [];

    List<User> blockedUsers = Provider.of<TeamAuthNotifier>(context, listen: false).blockedUsers;

    tempMessages = List.generate(list.length,
        (index) => Message.fromJson({...list[index].data() as Map<String, dynamic>, "messageID": list[index].id}));
    tempMessages = List<Message>.of(tempMessages.reversed);
    tempMessages.removeWhere((element) {
      bool choice = false;
      blockedUsers.forEach((blocked) {
        choice = element.senderId == blocked.uid;
      });

      return choice;
    });

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

  bool getIsWithinTimeFrame(int index) {
    if (getIsInGroup(index)) {
      if (getIsMessageLastInGroup(index)) {
        if (index == 0) return false;

        if ((messages[index - 1].createdAt!.minute - messages[index].createdAt!.minute).abs() <= 10) {
          return false;
        }
      } else if (getIsMessageFirstInGroup(index)) {
        if ((messages[index - 1].createdAt!.minute - messages[index].createdAt!.minute).abs() <= 10) {
          return false;
        }
      }
    } else {
      return true;
    }

    return false;
  }
}
