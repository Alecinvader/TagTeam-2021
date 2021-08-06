import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  final Color primary = Color(0xFF172A3A);
  final Color accent = Color(0xFF23C5C6);

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
                host: Platform.isAndroid ? '10.0.2.2:8080' : 'localhost:8080',
                sslEnabled: false);

            FirebaseStorage.instance.useStorageEmulator('10.0.2.2', 9199);

            // FirebaseFunctions.instance.useFunctionsEmulator(origin: 'http://localhost:5001');
          }

          return MaterialApp(
            theme: ThemeData(
              iconTheme: IconThemeData(color: Colors.white),
              unselectedWidgetColor: Colors.white60,
              textTheme: Typography.material2018().white,
              textSelectionTheme:
                  TextSelectionThemeData(cursorColor: accent, selectionColor: accent, selectionHandleColor: accent),
              inputDecorationTheme: InputDecorationTheme(
                  focusColor: accent,
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  labelStyle: TextStyle(color: Colors.white)),
              primaryColor: primary,
              scaffoldBackgroundColor: primary,
              accentColor: accent,
            ),
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
