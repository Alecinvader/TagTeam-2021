import 'package:flutter/material.dart';
import 'package:tagteamprod/server/errors/snackbar_error_handler.dart';
import 'package:tagteamprod/server/login/login_api.dart';
import 'package:tagteamprod/ui/login/splash_page.dart';
import 'package:tagteamprod/ui/primary/home_page.dart';

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
                              // decoration: borderStyle.copyWith(labelText: 'Email Address'),

                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(
                              height: 16.0,
                            ),
                            TextFormField(
                              initialValue: _key,
                              obscureText: true,
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
                                onPressed: !_loading
                                    ? () async {
                                        await LoginServices().login(_email, _key, SnackbarErrorHandler(context));

                                        print('did this');

                                        await Navigator.push(
                                            context, MaterialPageRoute(builder: (context) => HomePage()));
                                      }
                                    : () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        Row(
                          children: <Widget>[
                            GestureDetector(
                                onTap: () => !_loading ? Navigator.pushNamed(context, 'landing-page') : null,
                                child: Text(
                                  'New user? Register here.',
                                  style: TextStyle(color: Theme.of(context).accentColor),
                                ))
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
