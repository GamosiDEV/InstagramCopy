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
  List uploadsId = [];

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
      if (_userCollection['profile-image-reference'] != null)
        setProfileImageUrl(_userCollection['profile-image-reference']);
    });
    getUploadsFromLoggedUser();
  }

  Future<void> uploadPost(File image, Map<String, dynamic> upload) async {
    print("uploadPost");
    sendUploadToStorage(image).then((value) {
      print("upload post .then");
      upload.addAll({"upload-storage-reference": value});
      sendUploadToFirestore(upload);
    });
  }

  Future<void> sendSavedPostToFirestore(Map<String, dynamic> data) async {
    await _firestore.collection('saves').add(data).then((value) {
      setSaveToUser(value.id);
    });
  }

  /*
  print("SendUploadToFirestore");
    await _firestore.collection('uploads').add(upload).then((value) {
      print(value.id);
      setUploadToUser(value.id);
    });
   */

  Future<String> sendUploadToStorage(File image) async {
    print("sendUploadToStorage");
    await _storage
        .ref(_userCollection['profile-image-reference'] + 'uploaded/')
        .child(image.path.split('/').last)
        .putFile(image);
    print("----");
    print(_userCollection['profile-image-reference'] +
        'uploaded/' +
        image.path.split('/').last +
        '/');
    return _userCollection['profile-image-reference'] +
        'uploaded/' +
        image.path.split('/').last +
        '/';
  }

  Future<void> sendUploadToFirestore(Map<String, dynamic> upload) async {
    print("SendUploadToFirestore");
    await _firestore.collection('uploads').add(upload).then((value) {
      print(value.id);
      setUploadToUser(value.id);
    });
  }

  Future<void> setUploadToUser(String id) async {
    await _firestore.collection('users').doc(_authUser?.uid).update({
      'uploads': FieldValue.arrayUnion([id])
    });
  }

  Future<void> setSaveToUser(String id) async {
    await _firestore
        .collection('users')
        .doc(_authUser?.uid)
        .get()
        .then((value) async {
      if (value['saves'] != null) {
        for (final i in value['saves']) {
          if (id == i) {//mecher aqui
            await _firestore.collection('users').doc(_authUser?.uid).update({
              'saves': FieldValue.arrayRemove([id])
            }).whenComplete((){
              _userCollection['saves'].removeWhere((item) => item == id);
            });
          }
        }
        await _firestore.collection('users').doc(_authUser?.uid).update({
          'saves': FieldValue.arrayUnion([id])
        });
      }
    });
    await _firestore.collection('users').doc(_authUser?.uid).update({
      'saves': FieldValue.arrayUnion([id])
    });
  }

  bool asSaved(String uploadId) {
    for (final i in _userCollection['saves']) {
      if (i == uploadId) {
        return true;
      }
    }
    return false;
  }

  Future<void> getUploadsFromLoggedUser() async {
    uploadsId = _userCollection['uploads'];
    print('uploadsid===');
    print(uploadsId);
    List<Map>? list = [];
    await _firestore.collection('uploads').get().then((value) {
      for (String id in uploadsId) {
        for (final upload in value.docs) {
          if (id == upload.id) {
            Map<String, dynamic> i = upload.data();
            i.addAll({'id': upload.id.toString()});
            list.add(i);
          }
        }
      }
      _uploadsFromUser = list;
    });

    // await _firestore
    //     .collection('users')
    //     .doc(_authUser?.uid)
    //     .collection('uploads')
    //     .get()
    //     .then((value) {
    //   _uploadsFromUser?.clear();
    //   if (value != null) {
    //     for (final map in value.docs) {
    //       Map<String, dynamic> i = map.data();
    //       i.addAll({'id': map.id.toString()});
    //       _uploadsFromUser?.add(i);
    //     }
    //   }
    // });
  }

  Future<Map<String, dynamic>> getDocumentOfUploadedImage(
      String? documentId) async {
    Map<String, dynamic> upload;
    upload = await _firestore
        .collection('uploads')
        .doc(documentId)
        .get()
        .then((value) {
      return value.data()!;
    });
    return upload;
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
    uploadsId = [];
  }
}
