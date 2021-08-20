import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../main.dart';

class LegalDocumentViewer extends StatefulWidget {
  final String assetName;
  final String? title;
  final bool readOnly;

  LegalDocumentViewer({Key? key, required this.assetName, this.title, this.readOnly = false}) : super(key: key);

  @override
  _LegalDocumentViewerState createState() => _LegalDocumentViewerState();
}

class _LegalDocumentViewerState extends State<LegalDocumentViewer> {
  String bodyText = "";
  late ScrollController _scrollController;
  late ScrollController _listController;
  bool reachedBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController();
    _listController = new ScrollController();

    rootBundle.loadString('assets/tos/${widget.assetName}').then((value) {
      if (value.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not load document'),
        ));
        Navigator.pop(context);
      }

      setState(() {
        bodyText = value;
      });
    }).catchError((error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not load document'),
      ));
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _listController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: !widget.readOnly ? Alignment.center : Alignment.centerLeft,
                        child: Text(
                          widget.title!,
                          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Scrollbar(
                  isAlwaysShown: true,
                  showTrackOnHover: true,
                  child: SingleChildScrollView(
                    child: Text(bodyText),
                  ),
                ),
              ),
              widget.readOnly
                  ? SizedBox.shrink()
                  : Container(
                      height: 74.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: Text('CANCEL'),
                            style: TextButton.styleFrom(
                              side: BorderSide(
                                width: 1.0,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 32.0,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: Text(
                              'ACCEPT',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: TextButton.styleFrom(
                              side: BorderSide(width: 1.0),
                            ),
                          )
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
