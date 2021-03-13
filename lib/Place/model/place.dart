import 'package:flutter/cupertino.dart';
import 'package:platzi_trips_app/User/model/user.dart';

class Place {
  String uid;
  String name;
  String description;
  String urlImage;
  int likes;
  User userOwner;

  Place({
    Key key,
    @required this.name,
    @required this.description,
    @required this.urlImage,
    this.likes,
    @required this.userOwner
  });
}
