import 'package:flutter/material.dart';

class ImageViewer extends StatefulWidget {
  final String primaryImage;
  final String messageId;

  const ImageViewer({Key? key, required this.primaryImage, required this.messageId}) : super(key: key);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close)),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.download_outlined))],
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              panEnabled: false, // Set it to false
              boundaryMargin: EdgeInsets.all(50),
              minScale: 0.5,
              maxScale: 2,
              child: Hero(
                tag: 'messageimage${widget.messageId}',
                child: Image.network(
                  widget.primaryImage,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;

                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
