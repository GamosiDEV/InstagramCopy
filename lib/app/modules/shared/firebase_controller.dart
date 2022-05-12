import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  User? _authUser;
  late Map _userCollection;

  String? profileImageUrl;
  List<Map>? _uploadsFromUser = [];

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

  Map? getLoggedUserCollection() {
    return _userCollection;
  }

  List<Map>? getUploadsFromUser() {
    return _uploadsFromUser;
  }

  Future<void> getCollectionOfLoggedUser() async {
    await _firestore
        .collection('users')
        .doc(_authUser?.uid)
        .get()
        .then((value) {
      _userCollection = value.data()!;
      if(_userCollection['profile-image-reference'] != null)
        setProfileImageUrl(_userCollection['profile-image-reference']);
    });
      getUploadsFromLoggedUser();

  }

  Future<void> getUploadsFromLoggedUser() async {
    await _firestore
        .collection('users')
        .doc(_authUser?.uid)
        .collection('uploads')
        .get()
        .then((value) {
      _uploadsFromUser?.clear();
      if (value != null) {
        for (final map in value.docs) {
          Map i = map.data();
          _uploadsFromUser?.add(i);
        }
      }
    });
  }

  Future<String> getUrlFromUploadedImage(String reference) async {
    return await _storage.ref(reference).getDownloadURL();
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
    _userCollection = {};
    _uploadsFromUser?.clear();
  }
}
