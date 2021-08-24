import 'package:flutter/material.dart';

class SuccessSnackBar {
  final Widget widget;
  final BuildContext context;

  SuccessSnackBar(this.context, {Key? key, required this.widget});

  showSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        content: Container(
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Theme.of(context).accentColor,
              ),
              SizedBox(
                width: 8.0,
              ),
              widget,
            ],
          ),
        )));
  }
}
