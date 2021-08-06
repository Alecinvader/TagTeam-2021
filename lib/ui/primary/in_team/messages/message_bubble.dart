import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/storage/storage_utility.dart';
import 'package:tagteamprod/ui/core/tagteam_constants.dart';
import '../../../../models/message.dart';
import '../../../core/tagteam_circleavatar.dart';

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

  String? imageRefDownloadLink;
  bool failedToLoadImage = false;

  @override
  void initState() {
    super.initState();
    int timesToAttempt = 0;
    int timesAttempted = 0;
    if (widget.message.imagePath != null) {
      // StorageUtility().getImageURL(widget.message.imagePath, SnackbarErrorHandler(context)).then((value) {
      //   setState(() {
      //     imageRefDownloadLink = value;
      //   });
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    showsMessageDate = widget.showsMessageDate;
    isFirstOfGroup = widget.isFirstOfGroup;
    isLastOfGroup = widget.isLastOfGroup;
    isInGroup = widget.isInGroup;

    return Column(
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
                            child: Text(
                              widget.message.message ?? 'bruh',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.0),
                            ),
                          ),
                        )
                      : Container(
                          decoration:
                              BoxDecoration(borderRadius: BorderRadius.circular(8.0), color: kLightBackgroundColor),
                          height: 250,
                          width: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              'http://10.0.0.2:9199/download/storage/v1/b/tagteam-3c6cb.appspot.com/o/channels%2F8YL5g2PH6VXtxlAFfx7g%2Fimage_picker2984324108794531058.jpg?generation=1628222240855&alt=media',
                              errorBuilder: (context, object, trace) {
                                print(trace);

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
                  // isMyMessage ? userAvatar : SizedBox.shrink(),
                ],
              )
            ],
          ),
        ),
      ],
    );
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
