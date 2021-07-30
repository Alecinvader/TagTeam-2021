import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 125,
          child: Image.asset('assets/images/TagTeamLogo.png'),
        ),
        const SizedBox(
          height: 24.0,
        ),
        Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).accentColor,
          ),
        ),
      ],
    );
  }
}
