import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagteamprod/server/login/login_api.dart';
import 'package:tagteamprod/ui/user/legal_document_viewer.dart';
import '../../server/errors/snackbar_error_handler.dart';
import '../../server/user/user_api.dart';
import '../../server/user/user_request.dart';
import '../primary/home_page.dart';

class SignUp extends StatefulWidget {
  final bool accountSetup;

  const SignUp({Key? key, required this.accountSetup}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _showSplashPage = false;
  bool _loading = false;

  String email = '';
  String pass = '';
  String confirmPass = '';
  String displayName = '';

  RemoteConfig remoteConfig = RemoteConfig.instance;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  final InputDecoration signInStyles = InputDecoration();

  List<FocusNode> nodes = List.generate(4, (index) => FocusNode());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(left: 24.0, top: 24.0, right: 24.0, bottom: 0.0),
              child: Form(
                key: _formKey,
                child: Builder(
                  builder: (context) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 125,
                        child: Image.asset('assets/images/TagTeamLogo.png'),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const SizedBox(
                            height: 16.0,
                          ),
                          TextFormField(
                            focusNode: nodes[0],
                            decoration: signInStyles.copyWith(labelText: 'Email'),
                            onChanged: (value) => email = value,
                            validator: (value) {
                              return validateEmail(value);
                            },
                            onFieldSubmitted: (String value) {
                              nodes[1].requestFocus();
                            },
                            // decoration: borderStyle.copyWith(labelText: 'Email Address'),

                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          TextFormField(
                            onFieldSubmitted: (String value) {
                              nodes[2].requestFocus();
                            },
                            focusNode: nodes[1],
                            decoration: signInStyles.copyWith(labelText: 'Display Name'),
                            onChanged: (value) => displayName = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a display name';
                              }
                              return null;
                            },
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          TextFormField(
                            onFieldSubmitted: (String value) {
                              nodes[3].requestFocus();
                            },
                            focusNode: nodes[2],
                            obscureText: true,
                            decoration: signInStyles.copyWith(labelText: 'Password'),
                            onChanged: (value) => pass = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              } else if (widget.accountSetup != true && value != confirmPass) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          !widget.accountSetup
                              ? TextFormField(
                                  focusNode: nodes[3],
                                  onFieldSubmitted: (String value) async {
                                    await signUp();
                                  },
                                  obscureText: true,
                                  decoration: signInStyles.copyWith(labelText: 'Confirm Password'),
                                  onChanged: (value) => confirmPass = value,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    } else if (value != pass) {
                                      return "Passwords do not match";
                                    }
                                    return null;
                                  },
                                  style: TextStyle(color: Colors.white),
                                )
                              : SizedBox(),
                          SizedBox(
                            height: 32.0,
                          ),
                          Material(
                            elevation: 5.0,
                            borderRadius: BorderRadius.circular(4.0),
                            color: !_loading ? Theme.of(context).accentColor : Colors.grey,
                            child: MaterialButton(
                              child: Text(
                                'Create Account',
                                style: TextStyle(color: Colors.white, fontSize: 16.0),
                              ),
                              onPressed: !_loading ? signUp : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<void> tryGetRemoteConfig() async {
    try {
      await remoteConfig.fetchAndActivate();
      await _initPackageInfo();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not fetch app version info")));
      setState(() {
        _loading = false;
      });
    }
  }

  Future signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    } else {
      _formKey.currentState!.save();
    }

    setState(() {
      _loading = true;
    });

    await tryGetRemoteConfig();

    if (remoteConfig.getString('minAppVersion') != _packageInfo.version) {
      setState(() {
        _loading = false;
        _showSplashPage = false;
      });
      String appUpdateLink = remoteConfig.getString('appUpdateLink');
      await LoginServices().showUpdateDialog(context, appUpdateLink);
      return;
    }

    try {
      UserCredential credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pass);

      await UserApi().createUser(UserRequest(email: email, uid: credential.user!.uid, displayName: displayName),
          SnackbarErrorHandler(context, showSnackBar: false));

      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);

      bool? acceptedawait = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LegalDocumentViewer(
                    assetName: 'tagteameula.txt',
                    title: 'End User License Agreement',
                  )));

      if (acceptedawait == true) {
        await UserApi().acceptEULA(SnackbarErrorHandler(context, onErrorHandler: () {
          throw "Could not accept terms";
        }));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Must accept terms in order to use app"),
        ));
        throw "Must accept terms";
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('userkey', pass);
      await prefs.setString('username', email);

      await Navigator.of(context)
          .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false);

      setState(() {
        _loading = false;
      });
    } catch (error) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  String? validateEmail(String? email) {
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email!);

    if (email.isEmpty) {
      return 'Please enter an email';
    } else if (!emailValid) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}
