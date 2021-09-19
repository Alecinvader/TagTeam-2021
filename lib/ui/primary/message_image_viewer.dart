import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:http/http.dart' as http;

class ImageViewer extends StatefulWidget {
  final String primaryImage;
  final String messageId;

  const ImageViewer({Key? key, required this.primaryImage, required this.messageId}) : super(key: key);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  bool imageSaved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close)),
        actions: [
          !imageSaved
              ? IconButton(
                  onPressed: () async {
                    setState(() {
                      imageSaved = true;
                    });
                    await _save(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Image saved'),
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                  icon: Icon(Icons.download_outlined))
              : SizedBox()
        ],
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: InteractiveViewer(
                  panEnabled: true, // Set it to false
                  boundaryMargin: EdgeInsets.all(50),
                  minScale: 0.5,
                  maxScale: 2,
                  child: Hero(
                    tag: 'messageimage${widget.messageId}',
                    child: CachedNetworkImage(
                      imageUrl: widget.primaryImage,
                      progressIndicatorBuilder: (context, url, progress) {
                        return Center(
                          child: CircularProgressIndicator(
                            value: progress.progress,
                          ),
                        );
                      },
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      )),
    );
  }

  _save(BuildContext context) async {
    try {
      var response = await http.readBytes(Uri.parse(widget.primaryImage));
      final result = await ImageGallerySaver.saveImage(response, quality: 80);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save image')));
      setState(() {
        imageSaved = false;
      });
    }
  }
}
