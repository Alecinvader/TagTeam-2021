import 'package:flutter/material.dart';

/// A helper utility to handle clicking off text fields and bypassing typical [TextField] behavior
class TextFieldToggler extends StatelessWidget {
  final Widget child;

  const TextFieldToggler({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: child,
    );
  }
}
