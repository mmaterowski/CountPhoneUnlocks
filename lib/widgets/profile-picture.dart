import 'package:flutter/material.dart';

class ProfilePicture {
  static final String pictureUrl = 'assets/images/profile-picture.jpg';

  static Material build() {
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
