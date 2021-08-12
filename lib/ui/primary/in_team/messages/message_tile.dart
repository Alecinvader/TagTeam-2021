import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/team/channels/channel_api.dart';
import '../../../../models/channel.dart';
import 'message_page.dart';

class MessagePageTile extends StatefulWidget {
  final Channel channel;

  const MessagePageTile({Key? key, required this.channel}) : super(key: key);

  @override
  _MessagePageTileState createState() => _MessagePageTileState();
}

class _MessagePageTileState extends State<MessagePageTile> {
  bool isNewMessage = false;

  SharedPreferences? _preferences;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        _preferences = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    checkIfMessageIsUnread(widget.channel).then((value) {
      isNewMessage = value;

      print(isNewMessage);
    });

    return InkWell(
      onTap: () async {
        setState(() {
          isNewMessage = false;
        });

        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SendMesssagePage(
                      channel: widget.channel,
                    )));
      },
      child: Container(
        height: 80,
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).accentColor, width: 1.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.channel.type == ChannelType.message ? Icons.chat_bubble : Icons.info_outline,
                color: Theme.of(context).accentColor,
              ),
            ),
            const SizedBox(
              width: 12.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.channel.name ?? "Unknown",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: isNewMessage ? Colors.white : Colors.white70),
                  ),
                  widget.channel.mostRecentMessage?.senderDisplayName != null
                      ? Text(
                          widget.channel.mostRecentMessage!.senderDisplayName! +
                              ': ' +
                              widget.channel.mostRecentMessage!.message!,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : const SizedBox()
                ],
              ),
            ),
            const SizedBox(
              width: 8.0,
            ),
            isNewMessage != false
                ? Align(
                    child: Container(
                      height: 15,
                      width: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).accentColor,
                        // borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                    ),
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }

  Future<bool> checkIfMessageIsUnread(Channel channel) async {
    if (_preferences == null) {
      return false;
    }

    bool containsKey = _preferences!.containsKey('${channel.id}');

    if (!containsKey) {
      if (channel.mostRecentMessage == null) {
        return false;
      } else if (channel.mostRecentMessage!.senderId != FirebaseAuth.instance.currentUser!.uid) return true;
    }

    DateTime? time = DateTime.tryParse(_preferences!.getString('${channel.id}') ?? '');

    if (time == null) {
      return true;
    } else if (channel.mostRecentMessage == null) {
      return false;
    } else if (channel.mostRecentMessage!.senderId != FirebaseAuth.instance.currentUser!.uid &&
        channel.mostRecentMessage!.createdAt!.isAfter(time)) {
      return true;
    }

    return false;
  }
}
