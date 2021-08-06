import 'dart:io';

import 'package:flutter/material.dart';

class ImageDialogConfirmation extends StatelessWidget {
  final String imagePath;
  final Function(bool value) onChoice;

  const ImageDialogConfirmation({Key? key, required this.imagePath, required this.onChoice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      children: [
        Container(
          height: 350,
          width: 250,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: Image.file(File(imagePath)).image,
              )),
        ),
        const SizedBox(
          height: 12.0,
        ),
        Container(
          width: 250,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    primary: Colors.grey),
                onPressed: () {
                  onChoice(false);
                  Navigator.pop(context);
                },
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    primary: Theme.of(context).accentColor),
                onPressed: () {
                  onChoice(true);
                  Navigator.pop(context);
                },
                child: Text(
                  'SEND',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
