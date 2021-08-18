import 'package:flutter/material.dart';
import 'package:tagteamprod/models/tagteam.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/team/team_api.dart';
import 'package:tagteamprod/ui/core/tagteam_circleavatar.dart';
import 'package:tagteamprod/ui/core/tagteam_constants.dart';
import 'package:tagteamprod/ui/utility/core/better_future_builder.dart';

class SearchForTeam extends StatefulWidget {
  const SearchForTeam({Key? key}) : super(key: key);

  @override
  _SearchForTeamState createState() => _SearchForTeamState();
}

class _SearchForTeamState extends State<SearchForTeam> {
  Future<TagTeam>? searchResult;
  TextEditingController _textEditingController = new TextEditingController();

  int? selectedTeamId;

  bool requestedToJoin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Search by Code'),
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
                        _textEditingController.text.isNotEmpty
                            ? SizedBox(
                                width: 30,
                                child: IconButton(
                                  iconSize: 15,
                                  onPressed: () {
                                    _textEditingController.clear();
                                  },
                                  icon: Icon(Icons.clear),
                                  padding: EdgeInsets.only(right: 4),
                                ),
                              )
                            : SizedBox(),
                        Expanded(
                          child: TextField(
                            controller: _textEditingController,
                            decoration: InputDecoration(
                                isCollapsed: true,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                hintText: "Search",
                                hintStyle: TextStyle(color: Colors.white60)),
                            onSubmitted: (String value) async {
                              setState(() {
                                searchResult = TeamApi().searchByInviteCode(value, SnackbarErrorHandler(context));
                              });
                            },
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              searchResult = TeamApi()
                                  .searchByInviteCode(_textEditingController.text, SnackbarErrorHandler(context));
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Icon(Icons.search_outlined, color: Colors.white60, size: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              searchResult != null
                  ? SimpleFutureBuilder(
                      future: searchResult!,
                      builder: (context, TagTeam? data) {
                        return ListTile(
                          title: Text(data!.name!),
                          trailing: TextButton(
                              onPressed: () async {
                                setState(() {
                                  searchResult = null;
                                });

                                await TeamApi().requestToJoinTeam(data.teamId!, SnackbarErrorHandler(context));
                              },
                              child: Text(
                                'Join',
                                style: TextStyle(color: Theme.of(context).accentColor),
                              )),
                          leading: TagTeamCircleAvatar(
                            url: data.imageLink ?? '',
                            onErrorReplacement: Image.asset(
                              'assets/images/TagTeamLogo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      })
                  : SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
