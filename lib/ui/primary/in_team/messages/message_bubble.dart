import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tagteamprod/models/provider/team_auth_notifier.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/team/channels/channel_api.dart';
import 'package:tagteamprod/server/team/team_api.dart';
import 'package:tagteamprod/server/user/user_api.dart';
import 'package:tagteamprod/ui/core/tagteam_constants.dart';
import 'package:tagteamprod/ui/primary/message_image_viewer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../models/message.dart';
import '../../../core/tagteam_circleavatar.dart';
import 'message_delete_action_dialog.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool showsMessageDate;
  final bool isFirstOfGroup;
  final bool isLastOfGroup;
  final bool isInGroup;
  final bool showTime;
  final String channelId;

  MessageBubble(
      {Key? key,
      required this.message,
      this.showsMessageDate = false,
      this.isFirstOfGroup = false,
      this.isLastOfGroup = false,
      this.isInGroup = false,
      required this.channelId,
      this.showTime = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        await showModalBottomSheet(
            context: context,
            elevation: 0,
            backgroundColor: Colors.transparent,
            builder: (context2) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Share.share(message.message!);
                        Navigator.pop(context2);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                'Share',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(context2);
                        if (message.imagePath == null) {
                          Clipboard.setData(ClipboardData(text: message.message));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message copied')));
                        } else {
                          await _save(context);

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image saved to photos')));
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                message.imagePath == null ? 'Copy Message' : 'Save Image',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    !isMyMessage
                        ? GestureDetector(
                            onTap: () async {
                              bool? choice = await showDialog(
                                  context: context2,
                                  builder: (context2) => DeleteActionDialog(
                                        title: 'Block ${message.senderDisplayName}?',
                                        bodyText: 'You will no longer to be able to this persons messages',
                                      ));
                              Navigator.pop(context2);
                              if (choice == true) {
                                await UserApi().blockUser(message.senderId!, SnackbarErrorHandler(context));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text('User blocked, please refresh')));
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Text(
                                      'Block User',
                                      style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                    Consumer<TeamAuthNotifier>(builder: (context, data, child) {
                      return data.isAdmin
                          ? !isMyMessage
                              ? GestureDetector(
                                  onTap: () async {
                                    bool? choice = await showDialog(
                                        context: context2,
                                        builder: (context2) => DeleteActionDialog(
                                              title: 'Remove ${message.senderDisplayName}?',
                                            ));
                                    Navigator.pop(context2);

                                    if (choice == true) {
                                      await TeamApi().removeUserFromTeam(
                                          data.currentTeam!.teamId!, message.senderId!, SnackbarErrorHandler(context));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(content: Text('User will be removed shortly.')));
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(24.0),
                                          child: Text(
                                            'Remove from team',
                                            style:
                                                TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox()
                          : GestureDetector(
                              onTap: () async {
                                bool? choice = await showDialog(
                                    context: context2,
                                    builder: (context2) => DeleteActionDialog(
                                          title: 'Report ${message.senderDisplayName}?',
                                          bodyText: message.message!,
                                        ));

                                Navigator.pop(context2);

                                if (choice == true) {
                                  await ChannelApi().reportUserMessage(message, SnackbarErrorHandler(context));

                                  ScaffoldMessenger.of(Get.context!)
                                      .showSnackBar(SnackBar(content: Text('User reported')));
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Text(
                                        'Report Message',
                                        style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                    }),
                    Consumer<TeamAuthNotifier>(builder: (context, data, _) {
                      return data.isAdmin && message.deleted != true
                          ? GestureDetector(
                              onTap: () async {
                                Navigator.pop(context2);

                                try {
                                  await FirebaseFirestore.instance
                                      .collection('channels')
                                      .doc(channelId)
                                      .collection('deletedMessages')
                                      .add(message.toCompleteJson());

                                  await FirebaseFirestore.instance
                                      .collection('channels')
                                      .doc(channelId)
                                      .collection('messages')
                                      .doc(message.messageId)
                                      .update({"message": "Message removed", "deleted": true});
                                } catch (error) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text('Could not remove message')));
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Text(
                                        'Delete Message',
                                        style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox();
                    }),
                  ],
                ),
              );
            });
      },
      child: Column(
        children: [
          showsMessageDate
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    DateFormat('MM/dd/yy').format(message.createdAt!),
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : SizedBox.shrink(),
          Padding(
            padding: columnPadding,
            child: Column(
              children: [
                isFirstOfGroup && !isMyMessage || (!isMyMessage && !isInGroup)
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(right: 64.0, left: 44.0, bottom: 2.0),
                          child: Text(
                            message.senderDisplayName!,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ))
                    : SizedBox.shrink(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    isMyMessage && showTime && !isInvite
                        ? Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              DateFormat.jm().format(message.createdAt!),
                              style: TextStyle(color: Colors.white54, fontSize: 11.0),
                            ),
                          )
                        : SizedBox.shrink(),
                    !isMyMessage ? userAvatar : SizedBox.shrink(),
                    messageContent(context),
                    !isMyMessage && showTime && !isInvite
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              DateFormat.jm().format(message.createdAt!),
                              style: TextStyle(color: Colors.white54, fontSize: 11.0),
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget messageContent(BuildContext context) {
    if (isImage && (message.deleted ?? false) == false) {
      return GestureDetector(
        onTap: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ImageViewer(
                        messageId: message.messageId!,
                        primaryImage: message.imagePath ?? '',
                      )));
        },
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0), color: kLightBackgroundColor),
          width: 200,
          height: 250,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Hero(
              tag: 'messageimage${message.messageId}',
              child: message.isFileImage == false || message.isFileImage == null
                  ? CachedNetworkImage(
                    memCacheHeight: 800,
                    memCacheWidth: 800,
                    maxWidthDiskCache: 800,
                    maxHeightDiskCache: 800,
                      imageUrl: message.imagePath ?? '',
                      
                      errorWidget: (context, object, trace) {
                        return Center(child: Text('Failed to load image'));
                      },
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(message.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, object, trace) {
                        return Center(child: Text('Failed to load image'));
                      },
                    ),
            ),
          ),
        ),
      );
    } else if (isInvite && (message.deleted ?? false) == false) {
      int? teamId = int.tryParse(message.message!.split(" ").last);
      var tempName = message.message!.split(" ");
      tempName.removeLast();
      String teamName = tempName.join(" ").toString();

      return Container(
        decoration: BoxDecoration(border: Border(), borderRadius: BorderRadius.circular(4.0)),
        width: 248,
        height: 168,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/images/TagTeamLogo.png',
                width: 80,
                height: 100,
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: kLightBackgroundColor,
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(4.0), bottomRight: Radius.circular(4.0))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          teamName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0, right: 8.0),
                      child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              onSurface: Colors.white, side: BorderSide(color: Theme.of(context).accentColor)),
                          onPressed: () async {
                            if (teamId != null) {
                              await TeamApi().requestToJoinTeam(teamId, SnackbarErrorHandler(context));
                            }
                          },
                          child: Text(
                            'JOIN',
                            style: TextStyle(color: Theme.of(context).accentColor),
                          )),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Flexible(
        child: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(color: messageColor, borderRadius: BorderRadius.circular(4.0)),
          child: Linkify(
            onOpen: (LinkableElement element) async {
              await _onOpen(element, context);
            },
            text: message.message ?? 'Missing Message',
            linkStyle: TextStyle(
              color: isMyMessage ? Colors.white : Colors.blue,
            ),
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.0,
                fontStyle: message.deleted == true ? FontStyle.italic : FontStyle.normal),
          ),
        ),
      );
    }
  }

  _save(BuildContext context) async {
    try {
      var response = await http.readBytes(Uri.parse(message.imagePath!));
      await ImageGallerySaver.saveImage(response, quality: 80);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save image')));
    }
  }

  Future<void> _onOpen(LinkableElement link, BuildContext context) async {
    if (await canLaunch(link.url)) {
      await launch(link.url, forceWebView: false, forceSafariVC: false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open link')));
    }
  }

  bool get isImage => message.imagePath != null;
  bool get isInvite => message.messageType == MessageType.invite;

  bool get isMyMessage => FirebaseAuth.instance.currentUser?.uid == message.senderId;

  Widget get avatarSpacer => SizedBox(
        width: 44.0,
      );
  Color get messageColor => isMyMessage ? kAccentMessageBubble : kLightBackgroundColor;
  Widget get userAvatar => isInGroup && isLastOfGroup || !isInGroup
      ? Padding(
          padding: isMyMessage ? EdgeInsets.only(left: 8.0) : EdgeInsets.only(right: 8.0),
          child: TagTeamCircleAvatar(
            url: message.senderPhoto ?? '',
            radius: 16,
          ),
        )
      : avatarSpacer;

  EdgeInsets get columnPadding {
    if (isMyMessage && isFirstOfGroup) {
      return EdgeInsets.only(left: 64.0, right: 16.0, top: 6.0, bottom: 2.0);
    } else if (isMyMessage && isLastOfGroup) {
      return EdgeInsets.only(left: 64.0, right: 16.0, bottom: 6.0);
    } else if (isMyMessage && isInGroup) {
      return EdgeInsets.only(left: 64.0, right: 16.0, bottom: 2.0);
    } else if (isMyMessage) {
      return EdgeInsets.only(left: 64.0, right: 16.0, bottom: 6.0, top: 6.0);
    }

    if (!isMyMessage && isFirstOfGroup) {
      return EdgeInsets.only(right: 48.0, left: 16.0, top: 6.0, bottom: 2.0);
    } else if (!isMyMessage && isLastOfGroup) {
      return EdgeInsets.only(right: 48.0, left: 20.0, bottom: 6.0);
    } else if (!isMyMessage && isInGroup) {
      return EdgeInsets.only(right: 48.0, left: 16.0, bottom: 2.0);
    } else if (!isMyMessage) {
      return EdgeInsets.only(right: 48.0, left: 20.0, bottom: 6.0, top: 6.0);
    }

    return EdgeInsets.all(16.0);

    // isMyMessage
    //   ? EdgeInsets.only(left: 64.0, right: 16.0, top: 6.0, bottom: 6.0)
    //   : EdgeInsets.only(right: 64.0, left: 16.0);
  }

  String formatTime(DateTime date, BuildContext context) {
    return TimeOfDay.fromDateTime(date).format(context);
  }

  // BoxDecoration get boxDecoration => isMyMessage ? BoxDecoration(color: messageColor, borderRadius: BorderRadius.only())
}
