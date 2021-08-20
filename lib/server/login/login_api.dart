import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tagteamprod/server/user/user_api.dart';
import 'package:tagteamprod/ui/user/legal_document_viewer.dart';
import '../auth_api.dart';
import '../errors/error_handler.dart';

class LoginServices {
  final AuthServer api = new AuthServer();

  Future<void> login(String email, String pass, ErrorHandler handler) async {
    try {
      UserCredential user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);

      String token = await user.user!.getIdToken();

      log(token);

      Map<String, dynamic> response = await api.post('/user/signin', {}, {}, handler, (json) {
        return json;
      });

      print(response);

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
