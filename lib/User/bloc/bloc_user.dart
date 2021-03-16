import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:platzi_trips_app/Place/model/place.dart';
import 'package:platzi_trips_app/Place/repository/firebase_storage_repository.dart';
import 'package:platzi_trips_app/User/repository/auth_repository.dart';
import 'package:platzi_trips_app/User/repository/cloud_firestore_api.dart';
import 'package:platzi_trips_app/User/repository/cloud_firestore_repository.dart';
import 'package:platzi_trips_app/User/model/user.dart' as userModel;
import 'package:platzi_trips_app/User/ui/widgets/profile_place.dart';

class UserBloc implements Bloc {

  final _auth_repository = AuthRepository();

  // Flujo de datos - Streams
  // Stream - Firebase
  // StreamController
  Stream<User> streamFirebase = FirebaseAuth.instance.authStateChanges();
  Stream<User> get authStatus => streamFirebase;
  Future<User> currentUser() async {
    User user = FirebaseAuth.instance.currentUser;
    return user;
  }
  //User get currentUser => FirebaseAuth.instance.currentUser;

  // Casos de uso
  // 1. SignIn a la aplicación Google
  Future<UserCredential> signIn() => _auth_repository.signInFirebase();

  // 2. Registrar usuario en base de datos
  final _cloudFirestoreRepository = CloudFirestoreRepository();
  void updateUserData(userModel.User user) => _cloudFirestoreRepository.updateUserDataFirestore(user);
  Future<void> updatePlaceData(Place place) => _cloudFirestoreRepository.updatePlaceData(place);

  // Para descargar imágenes de Firebase Storage y mostrarlas en Flutter
  Stream<QuerySnapshot> placesListStream
    = FirebaseFirestore.instance.collection(CloudFirestoreAPI().PLACES).snapshots();

  Stream<QuerySnapshot> get placestream => placesListStream;
  List<ProfilePlace> buildPlaces(List<DocumentSnapshot> placesListSnapshot)
  => _cloudFirestoreRepository.buildPlaces(placesListSnapshot);

  Stream<QuerySnapshot> myPlacesListStream(String uid)
    => FirebaseFirestore.instance.collection(CloudFirestoreAPI().PLACES)
          .where("userOwner", isEqualTo: FirebaseFirestore.instance.doc("${CloudFirestoreAPI().USERS}/${uid}"))
          .snapshots();

  final _firebaseStorageRepository = FirebaseStorageRepository();

  Future<UploadTask> uploadFile(String path, File image) => _firebaseStorageRepository.uploadFile(path, image);


  signOut() {
    _auth_repository.signOut();
  }

  @override
  void dispose() {

  }

}