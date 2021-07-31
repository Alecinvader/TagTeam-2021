import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/message.dart';
import '../../../core/tagteam_circleavatar.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool showsMessageDate;
  final bool isFirstOfGroup;
  final bool isLastOfGroup;

  MessageBubble(
      {Key? key,
      required this.message,
      this.showsMessageDate = false,
      this.isFirstOfGroup = false,
      this.isLastOfGroup = false})
      : super(key: key);

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool showsMessageDate = false;
  bool isFirstOfGroup = false;
  bool isLastOfGroup = false;

  @override
  Widget build(BuildContext context) {
    showsMessageDate = widget.showsMessageDate;
    isFirstOfGroup = widget.isFirstOfGroup;
    isLastOfGroup = widget.isLastOfGroup;

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
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  !isMyMessage ? userAvatar : SizedBox.shrink(),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(color: messageColor, borderRadius: BorderRadius.circular(4.0)),
                      child: Text(
                        widget.message.message!,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.0),
                      ),
                    ),
                  ),
                  isMyMessage ? userAvatar : SizedBox.shrink(),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  bool get isMyMessage => FirebaseAuth.instance.currentUser?.uid == widget.message.senderId;
  bool get isInGroup => isFirstOfGroup || isLastOfGroup;
  Color get messageColor => isMyMessage ? Theme.of(context).accentColor : Colors.blue;
  Widget get userAvatar => isInGroup && isLastOfGroup || !isInGroup
      ? Padding(
          padding: isMyMessage ? EdgeInsets.only(left: 8.0) : EdgeInsets.only(right: 8.0),
          child: TagTeamCircleAvatar(
            url: widget.message.senderPhoto ?? '',
            radius: 18,
          ),
        )
      : SizedBox.shrink();

  EdgeInsets get columnPadding =>
      isMyMessage ? EdgeInsets.only(left: 64.0, right: 16.0) : EdgeInsets.only(right: 64.0, left: 16.0);

  String formatTime(DateTime date, BuildContext context) {
    return TimeOfDay.fromDateTime(date).format(context);
  }

  // BoxDecoration get boxDecoration => isMyMessage ? BoxDecoration(color: messageColor, borderRadius: BorderRadius.only())
}
