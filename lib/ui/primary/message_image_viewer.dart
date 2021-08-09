import 'package:flutter/material.dart';

class ImageViewer extends StatefulWidget {
  final String primaryImage;

  const ImageViewer({Key? key, required this.primaryImage}) : super(key: key);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Image'),
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
                tag: 'messageimage${widget.primaryImage}',
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
