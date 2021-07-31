import 'package:flutter/material.dart';
import 'package:tagteamprod/models/channel.dart';

class MessagePageTile extends StatefulWidget {
  final Channel channel;

  const MessagePageTile({Key? key, required this.channel}) : super(key: key);

  @override
  _MessagePageTileState createState() => _MessagePageTileState();
}

class _MessagePageTileState extends State<MessagePageTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        // setState(() {
        //   newMessage = false;
        // });
        // await Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => MessagePage(
        //               channel: widget.channel,
        //             )));
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
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
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
            // newMessage != null && newMessage != false
            //     ? Align(
            //         child: Container(
            //           height: 15,
            //           width: 45,
            //           decoration: BoxDecoration(
            //             shape: BoxShape.circle,
            //             color: Theme.of(context).accentColor,
            //             // borderRadius: BorderRadius.all(Radius.circular(5.0)),
            //           ),
            //         ),
            //       )
            //     : const SizedBox()
          ],
        ),
      ),
    );
  }
}
