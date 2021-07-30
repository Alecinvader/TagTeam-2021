import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:tagteamprod/config.dart';
import 'package:tagteamprod/ui/login/sign_in.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

enum ApplicationMode { dev, prod }

class _AppState extends State<App> {
  ApplicationMode appMode = EnvConfig.applicationMode;

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Text('Could not initalize project');
        }

        if (snapshot.connectionState == ConnectionState.done) {
          if (appMode == ApplicationMode.dev) {
            FirebaseFirestore.instance.settings = Settings(
                persistenceEnabled: false,
                host: Platform.isAndroid ? '10.0.2.2:8081' : 'localhost:8081',
                sslEnabled: false);

            // FirebaseFunctions.instance.useFunctionsEmulator(origin: 'http://localhost:5001');
          }

          return MaterialApp(
            home: SignIn(),
            title: 'TagTeam',
            debugShowCheckedModeBanner: false,
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return CircularProgressIndicator();
      },
    );
  }
}