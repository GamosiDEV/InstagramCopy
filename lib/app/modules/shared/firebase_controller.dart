import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  User? _authUser;
  Map<String, dynamic>? _userCollection;

  Future<UserCredential> signInFirebase(String _email, String _senha) async {
    return await _auth.signInWithEmailAndPassword(
        email: _email, password: _senha);
  }

  void setAuthUser(final user) {
    _authUser = user;
  }

  User? getAuthUser() {
    return _authUser;
  }

  void getCollectionOfLoggedUser() async {
    await _firestore
        .collection('users')
        .doc(_authUser?.uid)
        .get()
        .then((value) {
      _userCollection = value.data()!;
    });
  }

  User? getLoggedUser()  {
    return _auth.currentUser;
  }

  // void testeUserCollection() {
  //   print("||||||||||");
  //   _userCollection?.forEach((key, value) {
  //     print(key.toString() + ': ' + value.toString());
  //   });
  //   print(_authUser?.uid);
  //   print(_authUser?.email);
  //   print(_authUser?.emailVerified);
  //   print("||||||||||");
  // }
}
