import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:tagteamprod/models/user.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/storage/storage_utility.dart';
import 'package:tagteamprod/server/user/user_api.dart';
import 'package:tagteamprod/ui/core/tagteam_circleavatar.dart';
import 'package:tagteamprod/ui/core/tagteam_constants.dart';
import 'package:tagteamprod/ui/utility/core/better_future_builder.dart';

class AccountInfo extends StatefulWidget {
  AccountInfo({
    Key? key,
  }) : super(key: key);

  @override
  _AccountInfoState createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  late Future<User> userInfo;

  String? updateImagePath;

  @override
  void initState() {
    super.initState();
    userInfo = UserApi().getUser(auth.FirebaseAuth.instance.currentUser!.uid, SnackbarErrorHandler(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Info'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: SimpleFutureBuilder(
            future: userInfo,
            builder: (context, User? data) {
              if (data == null) {
                return Center(child: Text('No user found'));
              }

              return Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 16.0,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await selectAndUploadImage(context);
                      },
                      child: Center(
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
                          url: updateImagePath != null ? updateImagePath! : data.profilePicture ?? '',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await selectAndUploadImage(context);
                      },
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text('Change Picture'),
                        ),
                      ),
                    ),
                    Divider(
                      color: Colors.white54,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text('Display Name'),
                    ),
                    Container(
                      decoration: BoxDecoration(color: kLightBackgroundColor),
                      child: ListTile(
                        title: Text(
                          data.displayName ?? 'Unknown',
                          style: TextStyle(),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> selectAndUploadImage(BuildContext context) async {
    final String imagePath = await StorageUtility().getImagePath(
        SnackbarErrorHandler(context, overrideErrorMessage: 'Access denied, please grant access in your settings.'));

    if (imagePath.isNotEmpty) {
      String ref = await StorageUtility().uploadFile(imagePath, 'teams/coverphoto', SnackbarErrorHandler(context));
      String? downloadUrl = await StorageUtility().getImageURL(ref, SnackbarErrorHandler(context));

      if (downloadUrl != null) {
        await UserApi()
            .updateUserImage(auth.FirebaseAuth.instance.currentUser!.uid, downloadUrl, SnackbarErrorHandler(context));
      }

      setState(() {
        updateImagePath = imagePath;
      });
    }
  }
}
