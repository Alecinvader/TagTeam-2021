import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  final Widget? bottomWidget;

  SplashPage({Key? key, this.bottomWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 100,
            child: Image.asset('assets/images/TagTeamLogo.png'),
          ),
          SizedBox(
            height: 24.0,
          ),
          Center(child: bottomWidget ?? SizedBox())
        ],
      ),
    );
  }
}
