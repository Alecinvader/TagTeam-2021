import 'package:flutter/material.dart';
import 'tagteam_constants.dart';

class TagTeamCircleAvatar extends StatefulWidget {
  final String url;
  final double radius;
  final String onErrorReplacement;

  TagTeamCircleAvatar({Key? key, required this.url, this.radius = 25.0, this.onErrorReplacement = ""})
      : super(key: key);

  @override
  _TagTeamCircleAvatarState createState() => _TagTeamCircleAvatarState();
}

class _TagTeamCircleAvatarState extends State<TagTeamCircleAvatar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      decoration: BoxDecoration(
        color: kLightBackgroundColor,
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.network(
          widget.url,
          errorBuilder: (context, object, trace) {
            return Icon(
              Icons.person_outline,
              color: Colors.white,
            );
          },
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
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}