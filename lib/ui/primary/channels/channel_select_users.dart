import 'package:flutter/material.dart';
import 'package:tagteamprod/models/channel.dart';
import 'package:tagteamprod/models/user.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/team/channels/channel_api.dart';
import 'package:tagteamprod/server/team/team_api.dart';
import 'package:tagteamprod/ui/core/tagteam_circleavatar.dart';
import 'package:tagteamprod/ui/core/tagteam_constants.dart';
import 'package:tagteamprod/ui/primary/in_team/team_message_list.dart';
import 'package:tagteamprod/ui/utility/core/better_future_builder.dart';

class ChannelAddUsers extends StatefulWidget {
  final int teamId;
  final Channel channel;

  ChannelAddUsers({Key? key, required this.teamId, required this.channel}) : super(key: key);

  @override
  _ChannelAddUsersState createState() => _ChannelAddUsersState();
}

class _ChannelAddUsersState extends State<ChannelAddUsers> {
  late Future<List<User>> userFuture;

  List<User> selectedUsers = [];

  Map<User, bool> selectedUserMap = new Map();

  String query = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userFuture = TeamApi().getUsersInTeam(widget.teamId, SnackbarErrorHandler(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () async {
          Channel temp = widget.channel;
          temp.users = selectedUserMap.keys.toList();

          await ChannelApi().createChannels(
              [temp],
              widget.teamId,
              SnackbarErrorHandler(context, onErrorHandler: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => TeamMessageList(teamId: widget.teamId)));
              }));

          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    color: kLightBackgroundColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                                isCollapsed: true,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                hintText: "Search",
                                hintStyle: TextStyle(color: Colors.white60)),
                            onChanged: (String value) {
                              setState(() {
                                query = value;
                              });
                            },
                          ),
                        ),
                        Icon(Icons.search_outlined, color: Colors.white60, size: 15),
                      ],
                    ),
                  ),
                ),
              ),
              SimpleFutureBuilder(
                builder: (context, List<User>? data) {
                  // TODO: refactor this into its own function

                  data!.sort((a, b) {
                    if (selectedUserMap[a] != null && selectedUserMap[b] != null) {
                      if (selectedUserMap[b] == true && selectedUserMap[a] == false) {
                        return 1;
                      } else {
                        return -1;
                      }
                    } else if (selectedUserMap[b] == true && selectedUserMap[a] == null) {
                      return 1;
                    }

                    return -1;
                  });

                  if (query.isNotEmpty) {
                    data = data
                        .where((element) => element.displayName!.toLowerCase().contains(query.toLowerCase()))
                        .toList();
                  }

                  return Expanded(
                      child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            User currentUser = data![index];

                            return ListTile(
                              // TODO: REfactor onTap and onChanged, they are the same thing
                              onTap: () {
                                if (selectedUserMap.containsKey(currentUser)) {
                                  setState(() {
                                    selectedUserMap.update(currentUser, (value) => !value);
                                  });
                                } else {
                                  setState(() {
                                    selectedUserMap.addAll({currentUser: true});
                                  });
                                }
                              },
                              title: Text(currentUser.displayName!),
                              leading: TagTeamCircleAvatar(
                                radius: 20,
                                url: currentUser.profilePicture ?? '',
                              ),
                              trailing: SizedBox(
                                child: Checkbox(
                                  onChanged: (bool? value) {
                                    if (selectedUserMap.containsKey(currentUser)) {
                                      setState(() {
                                        selectedUserMap.update(currentUser, (value) => !value);
                                      });
                                    } else {
                                      setState(() {
                                        selectedUserMap.addAll({currentUser: true});
                                      });
                                    }
                                  },
                                  value: selectedUserMap[currentUser] ?? false,
                                ),
                              ),
                            );
                          }));
                },
                future: userFuture,
              )
            ],
          ),
        ),
      ),
    );
  }
}
