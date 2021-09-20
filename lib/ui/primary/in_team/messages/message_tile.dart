import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagteamprod/models/provider/team_auth_notifier.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/team/channels/channel_api.dart';
import '../../../../models/channel.dart';
import 'message_page.dart';

class MessagePageTile extends StatefulWidget {
  final Channel channel;
  final SharedPreferences prefs;
  final DateTime newestDate;
  final String newestSenderId;

  const MessagePageTile({
    Key? key,
    required this.channel,
    required this.prefs,
    required this.newestDate,
    required this.newestSenderId,
  }) : super(key: key);

  @override
  _MessagePageTileState createState() => _MessagePageTileState();
}

class _MessagePageTileState extends State<MessagePageTile> {
  bool isNewMessage = false;

  SharedPreferences? _preferences;
  late DateTime? time;
  @override
  void initState() {
    super.initState();
    _preferences = widget.prefs;
    time = DateTime.tryParse(_preferences!.getString('${widget.channel.id}') ?? '');

    if (time == null) {
      _preferences!.setString('${widget.channel.id}', DateTime.now().toIso8601String());
    }
  }

  @override
  Widget build(BuildContext context) {
    checkIfMessageIsUnread();

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

        setState(() {
          isNewMessage = false;
        });
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
            Consumer<TeamAuthNotifier>(builder: (context, data, _) {
              bool? canShowMostRecent = true;

              data.blockedUsers.forEach((element) {
                if (element.uid == widget.channel.mostRecentMessage?.senderId) {
                  canShowMostRecent = false;
                } else {
                  canShowMostRecent = true;
                }
              });

              return Expanded(
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
                            canShowMostRecent == true
                                ? widget.channel.mostRecentMessage!.senderDisplayName! +
                                    ': ' +
                                    widget.channel.mostRecentMessage!.message!
                                : 'Blocked User: Hidden message',
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
              );
            }),
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

  void checkIfMessageIsUnread() {
    time = DateTime.tryParse(_preferences!.getString('${widget.channel.id}') ?? '');
    if (time != null) {
      if (widget.newestDate.isAfter(time!) && widget.newestSenderId != FirebaseAuth.instance.currentUser!.uid) {
        isNewMessage = true;
      } else {
        isNewMessage = false;
      }
    }
  }
}
