import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:platzi_trips_app/Place/model/place.dart';
import 'package:platzi_trips_app/Place/ui/widgets/card_image.dart';
import 'package:platzi_trips_app/User/model/user.dart';
import 'package:platzi_trips_app/User/ui/widgets/profile_place.dart';

class CloudFirestoreAPI {
  final String USERS = "users";
  final String PLACES = "places";

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;


  Future<void> updateUserData(User user) async {
    CollectionReference users = _db.collection(USERS);
    DocumentReference ref = users.doc(user.uid);

    return await ref.set({
      'uid': user.uid,
      'name': user.name,
      'email': user.email,
      'photoURL': user.photoURL,
      'myPlaces': user.myPlaces,
      'myFavoritePlaces': user.myFavoritePlaces,
      'lastSignIn': DateTime.now()
    }, SetOptions(merge: true));
  }

  Future<void> updatePlaceData(Place place) async {
    CollectionReference refPlaces = _db.collection(PLACES);
    String uid = _auth.currentUser.uid;

    await refPlaces.add({
      'name': place.name,
      'description': place.description,
      'likes': place.likes,
      'userOwner': _db.doc("${USERS}/$uid"),
      'urlImage': place.urlImage,
    }).then((dr) {
      dr.get().then((snapshot) {
        snapshot.id; // ID Places
        DocumentReference refUsers = _db.collection(USERS).doc(uid);
        refUsers.update({
          'myPlaces': FieldValue.arrayUnion([_db.doc("$PLACES/${snapshot.id}")])
        });
      });
    });
  }

  List<ProfilePlace> buildMyPlaces(List<DocumentSnapshot> placesListSnapshot) {
    List<ProfilePlace> profilePlaces = [];
    placesListSnapshot.forEach((element) {
      profilePlaces.add(ProfilePlace(
        Place(
          name: element.data()['name'],
          description: element.data()['description'],
          urlImage: element.data()['urlImage'],
          likes: element.data()['likes'],
        )
      ));
    });

    return profilePlaces;
  }

  List<CardImageWithFabIcon> buildPlaces(List<DocumentSnapshot> placesListSnapshot) {
    List<CardImageWithFabIcon> placesCard = [];

    double width = 300.0;
    double height = 300.0;
    double left = 20.0;
    IconData iconData = Icons.favorite_border;

    placesListSnapshot.forEach((element) {
      placesCard.add(CardImageWithFabIcon(
          pathImage: element.data()['urlImage'],
          width: width,
          height: height,
          left: left,
          onPressedFabIcon: () {
            // Like
            likePlace(element.id);
          },
          iconData: iconData)
      );
    });

    return placesCard;
  }

  Future likePlace(String idPlace) async {
    await _db.collection(PLACES).doc(idPlace).get().then((value) {
      int likes = value.data()['likes'];

      _db.collection(PLACES).doc(idPlace).update({
        'likes': likes+1
      });
    });
  }
}
