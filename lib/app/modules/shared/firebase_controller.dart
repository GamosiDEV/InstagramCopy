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
  late Map _userCollection ;
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

  Map? getLoggedUserCollection(){
    return _userCollection;
  }

  Future<void> getCollectionOfLoggedUser() async {

    await _firestore
        .collection('users')
        .doc(_authUser?.uid)
        .get()
        .then((value) {
          _userCollection = value.data()!;
      setProfileImageUrl(_userCollection['profile-image-reference']);
    });
  }

  Future<void> setCollectionOfLoggedUser(Map<String,dynamic> userCollection) async {
    await _firestore.collection('users')
        .doc(_auth.currentUser?.uid).set(userCollection);
  }

  Future<void> updateProfileImage(String reference, String path) async {
    await _storage.ref(reference)
        .child('profile')
        .putFile(File(path));
  }

  String? getProfileImageUrl() {
    return profileImageUrl;
  }

  void setProfileImageUrl(String ref) async{
    await _storage.ref(ref+'profile').getDownloadURL().then((value){
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

  void clearLoggedUserData(){
    _authUser = null;
    _userCollection = {};
  }
}