import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ViewPhoto extends StatefulWidget {
  final url;
  ViewPhoto(this.url);
  @override
  _ViewPhotoState createState() => _ViewPhotoState();
}

class _ViewPhotoState extends State<ViewPhoto> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          leading: BackButton(
            color: Colors.white,
          ),
          backgroundColor: Colors.transparent),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: widget.url,
            placeholder: (context, url) => Container(
              width: 30,
              height: 30,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            fit: BoxFit.fitWidth,
          ),
          minScale: 0.1,
          maxScale: 5.0,
        ),
      ),
    );
  }
}
