import 'package:flutter/material.dart';

class TeamCreateChannels extends StatefulWidget {
  const TeamCreateChannels({Key? key}) : super(key: key);

  @override
  _CreateMultipleChannelsState createState() => _CreateMultipleChannelsState();
}

class _CreateMultipleChannelsState extends State<TeamCreateChannels> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          child: Column(),
        ),
      ),
    );
  }
}
