import 'package:flutter/material.dart';
import 'package:tagteamprod/ui/core/tagteam_constants.dart';

class ScrollDownMessageButton extends StatelessWidget {
  final VoidCallback onPressed;
  final int unreadCount;

  const ScrollDownMessageButton({Key? key, required this.onPressed, this.unreadCount = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
      color: kLightBackgroundColor,
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.all(8.0),
          width: 70,
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'New',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
              SizedBox(
                width: 8.0,
              ),
              Icon(
                Icons.arrow_downward,
                size: 16.0,
                color: Theme.of(context).accentColor,
              ),
            ],
          ),
          decoration: BoxDecoration(
            color: kLightBackgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
        ),
      ),
    );
  }
}
