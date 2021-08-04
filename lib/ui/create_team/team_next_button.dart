import 'package:flutter/material.dart';

class CircleNextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool enabled;

  CircleNextButton({Key? key, required this.onPressed, this.enabled = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.red,
      borderRadius: BorderRadius.circular(50),
      onTap: enabled ? onPressed : null,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: enabled ? Theme.of(context).accentColor : Colors.grey,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
        ),
      ),
    );
  }
}
