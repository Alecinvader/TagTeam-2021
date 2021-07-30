import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tagteamprod/server/auth_api.dart';
import 'package:tagteamprod/server/errors/error_handler.dart';
import 'package:tagteamprod/server/errors/error_type.dart';
import 'package:tagteamprod/server/safe_server.dart';
import 'package:tagteamprod/ui/login/sign_up.dart';

class LoginServices {
  final AuthServer api = new AuthServer();

  Future<void> login(String email, String pass, ErrorHandler handler) async {
    try {
      UserCredential user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);

      String token = await user.user!.getIdToken();

      log(token);

      await api.post('/user/signin', {}, {}, handler, (json) {
        return json;
      });
    } on FirebaseAuthException catch (authError) {
      ScaffoldMessenger.of(handler.context!).showSnackBar(SnackBar(
        content: Text(authError.message ?? 'Unkown error occured with FirebaseAuth'),
      ));
      throw authError;
    }
  }
}
