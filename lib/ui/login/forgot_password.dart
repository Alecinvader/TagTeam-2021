import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool _loading = false;
  String _email = '';

  bool sentOnce = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Reset Password'),
      ),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.only(left: 24.0, top: 24.0, right: 24.0, bottom: 0.0),
        child: Column(
          children: [
            SizedBox(
              height: 24.0,
            ),
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
                Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(4.0),
                  color: !_loading ? Theme.of(context).accentColor : Colors.grey,
                  child: MaterialButton(
                    child: Text(
                      !sentOnce ? 'Send Email' : 'Resend Email',
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                    onPressed: !_loading ? sendResetEmail : () {},
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16.0,
            ),
          ],
        ),
      )),
    );
  }

  Future<void> sendResetEmail() async {
    setState(() {
      sentOnce = true;
    });
    await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reset email sent.')));
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
