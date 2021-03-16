import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:platzi_trips_app/Place/model/place.dart';
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

  List<Place> buildPlaces(List<DocumentSnapshot> placesListSnapshot, User user) {

    List<Place> places = [];

    placesListSnapshot.forEach((element) {

      Place place = Place(
          uid: element.id,
          name: element.data()["name"],
          description: element.data()["description"],
          urlImage: element.data()["urlImage"],
          likes: element.data()["likes"]
      );

      List usersLikedRefs =  element.data()["usersLiked"];
      place.liked = false;

      usersLikedRefs?.forEach((refUL) {
        if(user.uid == refUL.documentID) {
          place.liked = true;
        }
      });
      places.add(place);
    });

    return places;
  }

  Future likePlace(Place place, String userId) async {
    await _db.collection(PLACES).doc(place.uid).get().then((value) {
      int likes = value.data()['likes'];

      _db.collection(PLACES).doc(place.uid).update({
        'likes': place.liked
            ? likes + 1
            : likes - 1,
        'usersLiked': place.liked
            ? FieldValue.arrayUnion([_db.doc("${USERS}/${userId}")])
            : FieldValue.arrayRemove([_db.doc("${USERS}/${userId}")])
      });
    });
  }
}
