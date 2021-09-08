import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tagteamprod/models/tagteam.dart';

class GenerateQRCode extends StatefulWidget {
  final TagTeam team;
  final String deepLink;
  GenerateQRCode({Key? key, required this.team, required this.deepLink}) : super(key: key);

  @override
  _GenerateQRCodeState createState() => _GenerateQRCodeState();
}

class _GenerateQRCodeState extends State<GenerateQRCode> {
  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
      ),
      // backgroundColor: colo,
      body: SafeArea(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 84.0,
              ),
              Text(
                widget.team.name ?? '',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 16.0,
              ),
              Center(
                child: QrImage(
                    foregroundColor: Theme.of(context).accentColor,
                    data: widget.deepLink,
                    version: QrVersions.auto,
                    size: 280,
                    gapless: false,
                    errorStateBuilder: (cxt, err) {
                      return Container(
                        child: Center(
                          child: Text(
                            "Uh oh! Something went wrong...",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }),
              ),
              SizedBox(
                height: 16.0,
              ),
              Text(
                'Scan to join',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
