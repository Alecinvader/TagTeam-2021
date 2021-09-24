import 'dart:io';

import 'package:flutter/material.dart';

class AdapativeBackIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Icon icon = Platform.isIOS ? Icon(Icons.arrow_back_ios) : Icon(Icons.arrow_back);

    return icon;
  }
}
