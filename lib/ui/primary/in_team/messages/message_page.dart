import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../models/channel.dart';
import '../../../../models/message.dart';
import '../../../../server/errors/snackbar_error_handler.dart';
import '../../../../server/team/channels/channel_api.dart';
import 'message_bubble.dart';
import '../../../utility/core/text_field_toggler.dart';
import '../../../utility/core/helper.dart';

class SendMesssagePage extends StatefulWidget {
  final Channel channel;

  SendMesssagePage({Key? key, required this.channel}) : super(key: key);

  @override
  _SendMesssagePageState createState() => _SendMesssagePageState();
}

class _SendMesssagePageState extends State<SendMesssagePage> {
  late Stream<QuerySnapshot> messageStream;
  late Channel channel;

  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    channel = widget.channel;
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
        elevation: 0,
        title: Text(channel.name!),
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
                      child: ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            return MessageBubble(
                                showsMessageDate: getIsMessageFirstOfDay(index), message: messages[index]);
                          })),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () async {
                        await ChannelApi().sendMessage(
                            110,
                            Message(
                                message:
                                    'Hello this is an epic test message! with some very long text that I am sending around to all my good friends and testing this blah blah blah.',
                                messageType: MessageType.text),
                            SnackbarErrorHandler(context, overrideErrorMessage: 'Failed to send message'));
                      },
                      child: Container(
                        height: 40,
                        child: Center(child: Text('TextBox')),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
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

  // bool getIsMessageFirstInGroup(int index) {

  // }

  // bool getIsMessageLastInGroup(int index) {}
}
