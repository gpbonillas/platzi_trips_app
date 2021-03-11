import 'package:firebase_auth/firebase_auth.dart';
import 'package:platzi_trips_app/User/repository/firebase_auth_api.dart';

class AuthRepository {

  final _firebaseAuth = FirebaseAuthAPI();
  Future<UserCredential> signInFirebase() => _firebaseAuth.signIn();

  signOut() => _firebaseAuth.signOut();
}