import 'package:flutter/cupertino.dart';

class Place {
  String uid;
  String name;
  String description;
  String urlImage;
  int likes;
  bool liked;

  Place({
    Key key,
    @required this.name,
    @required this.description,
    @required this.urlImage,
    @required this.likes,
    this.liked,
    this.uid,
  });
}
