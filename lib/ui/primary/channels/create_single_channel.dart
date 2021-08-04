import 'package:flutter/material.dart';
import 'package:tagteamprod/models/channel.dart';
import 'package:tagteamprod/models/message.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/team/channels/channel_api.dart';
import 'package:tagteamprod/ui/core/tagteam_constants.dart';

class CreateSingleChannel extends StatefulWidget {
  final int? teamId;

  CreateSingleChannel({Key? key, this.teamId}) : super(key: key);

  @override
  _CreateSingleChannelState createState() => _CreateSingleChannelState();
}

class _CreateSingleChannelState extends State<CreateSingleChannel> {
  ChannelType selectedMessageType = ChannelType.message;

  Channel channel = new Channel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text('New Channel'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(left: 16.0, top: 32.0, bottom: 10.0),
                child: Text(
                  'Channel Name',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0, color: Colors.white70),
                ),
              ),
              Container(
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                  child: TextFormField(
                    onFieldSubmitted: (String value) {
                      setState(() {
                        channel.name = value;
                      });
                    },
                    decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16.0)),
                  )),
              Container(
                padding: EdgeInsets.only(left: 16.0, top: 32.0, bottom: 10.0),
                child: Text(
                  'Channel Type',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0, color: Colors.white70),
                ),
              ),
              Container(
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          selectedMessageType = ChannelType.message;
                        });
                      },
                      title: Text('Message'),
                      trailing: Radio<ChannelType>(
                        focusColor: Colors.grey,
                        value: ChannelType.message,
                        groupValue: selectedMessageType,
                        onChanged: (value) {
                          setState(() {
                            selectedMessageType = value!;
                          });
                        },
                      ),
                      subtitle: Text('Open messaging between members of channel'),
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  )),
              Container(
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          selectedMessageType = ChannelType.announcment;
                        });
                      },
                      trailing: Radio<ChannelType>(
                        focusColor: Colors.grey,
                        value: ChannelType.announcment,
                        groupValue: selectedMessageType,
                        onChanged: (value) {
                          setState(() {
                            selectedMessageType = value!;
                          });
                        },
                      ),
                      title: Text('Announcement'),
                      subtitle: Text('Only owner & moderators can send messages in this channel'),
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  )),
              SizedBox(
                height: 36.0,
              ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(
                                width: 32.0,
                              ),
                              Text('Invite Only')
                            ],
                          ),
                        ),
                      ),
                      Switch.adaptive(
                          value: channel.public ?? false,
                          onChanged: (value) {
                            setState(() {
                              channel.public = value;
                            });
                          })
                    ],
                  )),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                      onPressed: () async {
                        channel.type = selectedMessageType;
                        channel.teamId = widget.teamId;
                        if (widget.teamId != null) {
                          await ChannelApi().createChannels([channel], widget.teamId!, SnackbarErrorHandler(context));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Channel will be created shortly'),
                            behavior: SnackBarBehavior.floating,
                          ));
                          Navigator.pop(context);
                        } else {
                          Navigator.pop(context, channel);
                        }
                      },
                      child: Text(
                        'CREATE',
                        style: TextStyle(color: Theme.of(context).accentColor),
                      )),
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
