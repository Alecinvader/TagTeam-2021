import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tagteamprod/server/user/user_api.dart';
import 'package:tagteamprod/ui/core/tagteam_constants.dart';
import 'package:tagteamprod/ui/user/legal_document_viewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth_api.dart';
import '../errors/error_handler.dart';

class LoginServices {
  final AuthServer api = new AuthServer();

  Future checkAndLaunchURL(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to open link')));
    }
  }

  Future showUpdateDialog(BuildContext context, String appUpdateLink) async {
    await showDialog(
        context: context,
        builder: (context) {
          if (Platform.isIOS) {
            return CupertinoAlertDialog(
              title: Text("Update Required"),
              content: Text("To login, please install latest the version"),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () async {
                    await checkAndLaunchURL(context, appUpdateLink);
                  },
                  isDefaultAction: true,
                  child: Text("UPDATE"),
                ),
              ],
            );
          }

          return SimpleDialog(
            backgroundColor: kLightBackgroundColor,
            title: Text('Update Required'),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Text('Unable to login until new version is installed'),
                    ButtonBar(
                      children: [
                        TextButton(
                            onPressed: () async {
                              await checkAndLaunchURL(context, appUpdateLink);
                            },
                            child: Text(
                              'UPDATE',
                              style: TextStyle(color: Theme.of(context).accentColor),
                            ))
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  Future<void> login(String email, String pass, ErrorHandler handler) async {
    try {
      UserCredential user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);

      String token = await user.user!.getIdToken();

      log(token);

      Map<String, dynamic> response = await api.post('/user/signin', {}, {}, handler, (json) {
        return json;
      });

      if (response['user']['acceptedEULA'] == 0) {
        bool? acceptedawait = await Navigator.push(
            handler.context!,
            MaterialPageRoute(
                builder: (context) => LegalDocumentViewer(
                      assetName: 'tagteameula.txt',
                      title: 'End User License Agreement',
                    )));

        if (acceptedawait == true) {
          await UserApi().acceptEULA(handler);
        } else {
          ScaffoldMessenger.of(handler.context!).showSnackBar(SnackBar(
            content: Text("Must accept terms in order to use app"),
          ));
          throw "Must accept terms";
        }
      }
    } on FirebaseAuthException catch (authError) {
      ScaffoldMessenger.of(handler.context!).showSnackBar(SnackBar(
        content: Text(authError.message ?? 'Unkown error occured with FirebaseAuth'),
      ));
      throw authError;
    } catch (error) {
      throw error;
    }
  }
}
