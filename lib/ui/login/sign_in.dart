import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tagteamprod/ui/login/forgot_password.dart';
import '../../server/errors/snackbar_error_handler.dart';
import '../../server/login/login_api.dart';
import 'sign_up.dart';
import 'splash_page.dart';
import '../primary/home_page.dart';

import '../../config.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _showSplashPage = false;
  bool _loading = false;

  String _email = EnvConfig().user;
  String _key = EnvConfig().pass;

  RemoteConfig remoteConfig = RemoteConfig.instance;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();

    remoteConfig.setDefaults(<String, dynamic>{'minAppVersion': _packageInfo.version, 'appUpdateLink': ''});
    remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: Duration(seconds: 10),
      minimumFetchInterval: Duration(minutes: 1),
    ));

    SharedPreferences.getInstance().then((SharedPreferences value) async {
      if (value.containsKey('userkey')) {
        setState(() {
          _showSplashPage = true;
          _email = value.getString('username')!;
          _key = value.getString('userkey')!;
        });

        signIn();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _showSplashPage
            ? SplashPage()
            : Container(
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
                              onChanged: (value) => _email = value,
                              validator: (value) {
                                return validateEmail(value);
                              },
                              initialValue: _email,
                              decoration: InputDecoration(labelText: 'Email'),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(
                              height: 16.0,
                            ),
                            TextFormField(
                              initialValue: _key,
                              obscureText: true,
                              decoration: InputDecoration(labelText: 'Password'),
                              onChanged: (value) => _key = value,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a valid password';
                                }
                                return null;
                              },
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(
                              height: 16.0,
                            ),
                            Material(
                              elevation: 5.0,
                              borderRadius: BorderRadius.circular(4.0),
                              color: !_loading ? Theme.of(context).accentColor : Colors.grey,
                              child: MaterialButton(
                                child: Text(
                                  'Sign in',
                                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                                ),
                                onPressed: !_loading ? signIn : () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            GestureDetector(
                                onTap: () => !_loading
                                    ? Navigator.push(
                                        context, MaterialPageRoute(builder: (context) => SignUp(accountSetup: false)))
                                    : null,
                                child: Text(
                                  'New? Sign up here.',
                                  style: TextStyle(color: Theme.of(context).accentColor),
                                )),
                            GestureDetector(
                                onTap: () => !_loading
                                    ? Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassword()))
                                    : null,
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(color: Theme.of(context).accentColor),
                                )),
                          ],
                        ),
                      ],
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

  Future<String?> tryGetRemoteConfig() async {
    try {
      await remoteConfig.fetchAndActivate();
      await _initPackageInfo();
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not fetch app version info")));
      setState(() {
        _loading = false;
        _showSplashPage = false;
      });
      return "Could not fetch remote config";
    }
  }

  Future signIn() async {
    setState(() {
      _loading = true;
    });

    String? remoteConfigError = await tryGetRemoteConfig();
    if (remoteConfigError != null) {
      return remoteConfigError;
    }
    String? appVersionError = await LoginServices().checkAppVersion(remoteConfig.getString('minAppVersion'),
        _packageInfo.version, remoteConfig.getString('appUpdateLink'), context);
    if (appVersionError != null) {
      setState(() {
        _loading = false;
        _showSplashPage = false;
      });
      return appVersionError;
    }

    try {
      await LoginServices().login(_email, _key, SnackbarErrorHandler(context));
    } catch (error) {
      setState(() {
        _loading = false;
        _showSplashPage = false;
      });
      throw error;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('userkey', _key);
    await prefs.setString('username', _email);

    await Navigator.of(context)
        .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false);

    setState(() {
      _loading = false;
      _showSplashPage = false;
    });
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
