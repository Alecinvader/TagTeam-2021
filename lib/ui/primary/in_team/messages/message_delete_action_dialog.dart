import 'package:flutter/material.dart';
import 'package:tagteamprod/ui/core/tagteam_constants.dart';

class DeleteActionDialog extends StatelessWidget {
  final String title;
  final String bodyText;

  const DeleteActionDialog({Key? key, required this.title, this.bodyText = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kLightBackgroundColor,
      title: Text(title),
      content: Text(bodyText),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text('CANCEL')),
        TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text('CONFIRM'))
      ],
    );
  }
}
