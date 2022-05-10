import 'dart:io';

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
  String? profileImageUrl;

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

  Map<String, dynamic>? getLoggedUserCollection() {
    return _userCollection;
  }

  // Future<Map> updateAndGetCollectionOfLoggedUser() async {
  //   getLoggedUserCollection()
  // }

  Future<void> getCollectionOfLoggedUser() async {
    await _firestore
        .collection('users')
        .doc(_authUser?.uid)
        .get()
        .then((value) {
      _userCollection = value.data()!;
      setProfileImageUrl(_userCollection!['profile-image-reference']);
    });
  }

  Future<void> setCollectionOfLoggedUser(
      Map<String, dynamic> userCollection) async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .set(userCollection);
  }

  Future<void> updateProfileImage(String reference, String path) async {
    await _storage.ref(reference).child('profile').putFile(File(path));
  }

  String? getProfileImageUrl() {
    return profileImageUrl;
  }

  void setProfileImageUrl(String ref) async {
    await _storage.ref(ref + 'profile').getDownloadURL().then((value) {
      profileImageUrl = value;
    });
  }

  User? getLoggedUser() {
    return _auth.currentUser;
  }

  Future<bool> signOut() async {
    await _auth.signOut();
    if (_auth.currentUser == null) {
      clearLoggedUserData();
      return false;
    }
    return true;
  }

  void clearLoggedUserData() {
    _authUser = null;
    _userCollection = null;
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
/*
      Container(
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 4.0),
                    child: Container(
                      child: ClipOval(
                        child: SizedBox.fromSize(
                          size: Size.fromRadius(40),
                          child: getCurrentProfileImage(),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '10',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const Text('Publicações')
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '280',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const Text('Seguidores')
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '780',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const Text('Seguindo')
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      fullNameText,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      bioText,
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.0),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Modular.to.pushNamed('/profile/editor/',arguments: widget.firebase);
                  },
                  child: Text(
                    'Editar perfil',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
 */
