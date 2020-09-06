import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final String pictureUrl;
  @override
  ProfilePicture({Key key, this.pictureUrl}) : super(key: key);
  Widget build(BuildContext context) {
    return Material(
      elevation: 4.0,
      shape: CircleBorder(),
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: Ink.image(
        image: AssetImage(pictureUrl),
        fit: BoxFit.contain,
        width: 80.0,
        height: 80.0,
        child: InkWell(
          onTap: () {},
        ),
      ),
    );
  }
}
