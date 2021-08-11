import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tagteamprod/config.dart';
import 'package:tagteamprod/main.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/storage/storage_utility.dart';
import 'package:tagteamprod/ui/core/tagteam_constants.dart';
import 'package:tagteamprod/ui/primary/message_image_viewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/message.dart';
import '../../../core/tagteam_circleavatar.dart';

import 'package:http/http.dart' as http;

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool showsMessageDate;
  final bool isFirstOfGroup;
  final bool isLastOfGroup;
  final bool isInGroup;

  MessageBubble(
      {Key? key,
      required this.message,
      this.showsMessageDate = false,
      this.isFirstOfGroup = false,
      this.isLastOfGroup = false,
      this.isInGroup = false})
      : super(key: key);

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool showsMessageDate = false;
  bool isFirstOfGroup = false;
  bool isLastOfGroup = false;
  bool isInGroup = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    isImage ? print(widget.message.imagePath) : print('');

    showsMessageDate = widget.showsMessageDate;
    isFirstOfGroup = widget.isFirstOfGroup;
    isLastOfGroup = widget.isLastOfGroup;
    isInGroup = widget.isInGroup;

    return GestureDetector(
      onLongPress: () async {
        await showModalBottomSheet(
            context: context,
            elevation: 0,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: () async {
                            // Share.share(widget.message.message!);
                            // Navigator.pop(context);

                            await _save();
                          },
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: () async {
                            if (widget.message.imagePath == null) {
                              Clipboard.setData(ClipboardData(text: widget.message.message));
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message copied')));
                            } else {
                              try {
                                // await GallerySaver.saveImage(widget.message.imagePath ?? '');
                              } catch (error) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text('Failed to save image')));
                                Navigator.pop(context);
                              }

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text('Image saved to photos')));
                            }
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              widget.message.imagePath == null ? 'Copy Message' : 'Save Image',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: () async {
                            // Navigator.pop(context);

                            // await FirebaseFirestore.instance
                            //     .collection('channels')
                            //     .doc('jdKAN5h7FRKE3VF5l76w')
                            //     .collection('messages')
                            //     .doc('DhroA2kQLck7AgYNny6t')
                            //     .delete();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'Remove Message',
                              style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            });
      },
      child: Column(
        children: [
          showsMessageDate
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    DateFormat('MM-dd-yy').format(widget.message.createdAt!),
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
                            widget.message.senderDisplayName!,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ))
                    : SizedBox.shrink(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    !isMyMessage ? userAvatar : SizedBox.shrink(),
                    !isImage
                        ? Flexible(
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(color: messageColor, borderRadius: BorderRadius.circular(4.0)),
                              child: Linkify(
                                onOpen: _onOpen,
                                text: widget.message.message ?? 'Missing Message',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.0),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () async {
                              if (widget.message.imagePath!.contains('channel'))
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ImageViewer(
                                              primaryImage:
                                                  widget.message.imagePath!,
                                            )));
                            },
                            child: Container(
                              decoration:
                                  BoxDecoration(borderRadius: BorderRadius.circular(8.0), color: kLightBackgroundColor),
                              height: 250,
                              width: 200,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Hero(
                                  tag:
                                      'messageimage${widget.message.imagePath}',
                                  child: Image.network(
                                    widget.message.imagePath!,
                                    errorBuilder: (context, object, trace) {
                                      if (widget.message.imagePath!.contains('channel')) return SizedBox();

                                      return Center(child: Text('Failed to load image'));
                                    },
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;

                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: progress.expectedTotalBytes != null
                                              ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                    // isMyMessage ? userAvatar : SizedBox.shrink(),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  _save() async {
    var response = await http.readBytes(Uri.parse(
        'https://ss0.baidu.com/94o3dSag_xI4khGko9WTAnF6hhy/image/h%3D300/sign=a62e824376d98d1069d40a31113eb807/838ba61ea8d3fd1fc9c7b6853a4e251f94ca5f46.jpg'));
    final result = await ImageGallerySaver.saveImage(response, quality: 100, name: "savingimage");
    print(result);
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (await canLaunch(link.url)) {
      await launch(link.url);
    } else {
      throw 'Could not launch $link';
    }
  }

  bool get isImage => widget.message.imagePath != null;

  bool get isMyMessage => FirebaseAuth.instance.currentUser?.uid == widget.message.senderId;

  Widget get avatarSpacer => SizedBox(
        width: 44.0,
      );
  Color get messageColor => isMyMessage ? Theme.of(context).accentColor : kLightBackgroundColor;
  Widget get userAvatar => isInGroup && isLastOfGroup || !isInGroup
      ? Padding(
          padding: isMyMessage ? EdgeInsets.only(left: 8.0) : EdgeInsets.only(right: 8.0),
          child: TagTeamCircleAvatar(
            url: widget.message.senderPhoto ?? '',
            radius: 18,
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
      return EdgeInsets.only(right: 64.0, left: 16.0, top: 6.0, bottom: 2.0);
    } else if (!isMyMessage && isLastOfGroup) {
      return EdgeInsets.only(right: 64.0, left: 16.0, bottom: 6.0);
    } else if (!isMyMessage && isInGroup) {
      return EdgeInsets.only(right: 64.0, left: 16.0, bottom: 2.0);
    } else if (!isMyMessage) {
      return EdgeInsets.only(right: 64.0, left: 16.0, bottom: 6.0, top: 6.0);
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
