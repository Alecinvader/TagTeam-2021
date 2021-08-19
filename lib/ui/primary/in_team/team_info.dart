import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tagteamprod/models/provider/team_auth_notifier.dart';
import 'package:tagteamprod/models/user.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/storage/storage_utility.dart';
import 'package:tagteamprod/server/team/team_api.dart';
import 'package:tagteamprod/ui/core/tagteam_circleavatar.dart';
import 'package:tagteamprod/ui/core/tagteam_constants.dart';
import 'package:tagteamprod/ui/primary/in_team/team_active_users.dart';
import 'package:tagteamprod/ui/primary/in_team/team_requests.dart';
import 'package:tagteamprod/ui/utility/core/better_future_builder.dart';

class TeamInfo extends StatefulWidget {
  TeamInfo({Key? key}) : super(key: key);

  @override
  _TeamInfoState createState() => _TeamInfoState();
}

class _TeamInfoState extends State<TeamInfo> {
  Future<List<User>>? pendingRequestsFuture;

  String? updateImagePath;

  bool nameChanged = false;

  TextEditingController? _titleController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text('Team Info'),
      ),
      backgroundColor: kLightBackgroundColor,
      body: SingleChildScrollView(
        child: Consumer<TeamAuthNotifier>(builder: (context, teamData, _) {
          bool isAdmin = false;

          if (teamData.authType == TeamAuthType.manager || teamData.authType == TeamAuthType.owner) {
            isAdmin = true;
            pendingRequestsFuture ??=
                TeamApi().allJoinRequests(teamData.currentTeam!.teamId!, SnackbarErrorHandler(context));
            _titleController ??= TextEditingController(text: teamData.currentTeam?.name ?? 'Untitled Team');
          }

          return SimpleFutureBuilder(
              future: pendingRequestsFuture ?? Future<List<User>>.value([]),
              builder: (context, List<User>? data) {
                return SafeArea(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 16.0,
                        ),
                        Center(
                          child: Hero(
                            tag: 'appbar-icon',
                            child: TagTeamCircleAvatar(
                              isFile: updateImagePath != null,
                              radius: 50,
                              onErrorReplacement: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                                child: Icon(Icons.camera_alt),
                              ),
                              url: updateImagePath != null ? updateImagePath! : teamData.currentTeam!.imageLink ?? '',
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Consumer<TeamAuthNotifier>(builder: (context, data, _) {
                          return data.isAdmin
                              ? GestureDetector(
                                  onTap: () async {
                                    await selectAndUploadImage(teamData.currentTeam!.teamId!, context);
                                  },
                                  child: Center(
                                      child: Text(
                                    'Change Picture',
                                    style: TextStyle(color: Theme.of(context).accentColor),
                                  )),
                                )
                              : SizedBox();
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text('Name'),
                        ),
                        Container(
                          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                          child: ListTile(
                              trailing: isAdmin && nameChanged == true
                                  ? TextButton(
                                      onPressed: () {
                                        setState(() {
                                          nameChanged = false;
                                        });
                                      },
                                      child: Text(
                                        'SAVE',
                                        style: TextStyle(color: Theme.of(context).accentColor),
                                      ))
                                  : null,
                              title: Text(
                                teamData.currentTeam?.name ?? 'Untitled Team',
                                overflow: TextOverflow.ellipsis,
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text('Invite Code'),
                        ),
                        Container(
                          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                          child: ListTile(
                            title: Text(
                              teamData.currentTeam?.inviteCode ?? 'No code',
                              style: TextStyle(),
                              overflow: TextOverflow.visible,
                            ),
                            trailing: TextButton(
                                onPressed: () async {
                                  String? string = await generateInvitLink(teamData.currentTeam!.inviteCode!);
                                  Share.share(string ?? 'Empty');
                                },
                                child: Text(
                                  'SHARE',
                                  style: TextStyle(color: Theme.of(context).accentColor),
                                )),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text('Members'),
                        ),
                        isAdmin
                            ? Container(
                                decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                                child: ListTile(
                                  onTap: () async {
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => TeamRequests(teamId: teamData.currentTeam!.teamId!)));
                                  },
                                  leading: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 35,
                                        padding: EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(color: kLightBackgroundColor, shape: BoxShape.circle),
                                        child: Center(child: Text(data!.length.toString())),
                                      ),
                                    ],
                                  ),
                                  title: Text('Pending Requests'),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              )
                            : SizedBox(),
                        Container(
                          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                          child: ListTile(
                            onTap: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TeamActiveUsers(teamId: teamData.currentTeam!.teamId!)));
                            },
                            leading: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.group_outlined,
                                  size: 25,
                                  color: Colors.white,
                                )
                              ],
                            ),
                            title: Text('Active Members'),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              });
        }),
      ),
    );
  }

  Future<void> selectAndUploadImage(int teamId, BuildContext context) async {
    final String imagePath = await StorageUtility().getImagePath(SnackbarErrorHandler(context));

    if (imagePath.isNotEmpty) {
      String ref = await StorageUtility().uploadFile(imagePath, 'teams/coverphoto', SnackbarErrorHandler(context));
      String? downloadUrl = await StorageUtility().getImageURL(ref, SnackbarErrorHandler(context));

      if (downloadUrl != null) {
        await TeamApi().updateImageLink(teamId, downloadUrl, SnackbarErrorHandler(context));
      }
      Provider.of<TeamAuthNotifier>(context, listen: false).updateImage(downloadUrl!);
      setState(() {
        updateImagePath = imagePath;
      });
    }
  }

  Future<String?> generateInvitLink(String inviteCode) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://tagteammobile.page.link',
      link: Uri.parse('https://tagteammobile.page.link.com/?invite=$inviteCode'),
      androidParameters: AndroidParameters(
        packageName: 'com.eyro.tagteamprod',
        minimumVersion: 1,
      ),
      // iosParameters: IosParameters(
      //   bundleId: 'com.example.ios',
      //   minimumVersion: '1.0.1',
      //   appStoreId: '123456789',
      // ),
      // googleAnalyticsParameters: GoogleAnalyticsParameters(
      //   campaign: 'example-promo',
      //   medium: 'social',
      //   source: 'orkut',
      // ),
      // itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
      //   providerToken: '123456',
      //   campaignToken: 'example-promo',
      // ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Invite to join team',
        description: 'An owner of a team on TagTeam has invited you to join',
      ),
    );

    final ShortDynamicLink shortenedLink = await DynamicLinkParameters.shortenUrl(
      Uri.parse(
          'https://tagteammobile.page.link/?link=https://tagteammobile.page.link.com/?code=$inviteCode/&apn=com.eyro.tagteamprod'),
      DynamicLinkParametersOptions(shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
    );

    final Uri shortUrl = shortenedLink.shortUrl;

    return shortUrl.toString();
  }
}
