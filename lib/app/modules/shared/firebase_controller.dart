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
  List savedsId = [];

  String? profileImageUrl;
  List<Map>? _uploadsFromUser = [];
  List<Map>? _savedsFromUser = [];

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

  List<Map>? getSavedsFromUser() {
    return _savedsFromUser;
  }

  Future<Map<String, dynamic>> getCollectionOfUserById(String userId) async {
    print(userId);
    return await _firestore
        .collection('users')
        .doc(userId)
        .get()
        .then((value) async {
      Map<String, dynamic> user = value.data()!;
      print(user);
      if (value.data()?['profile-image-reference'] != null &&
          value.data()?['profile-image-reference'] != '') {
        await _storage
            .ref(value.data()?['profile-image-reference'] + 'profile')
            .getDownloadURL()
            .then((value) {
          user.addAll({'url': value});
        });
      }
      return user;
    });
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
    getSavedsFromLoggedUser();
  }

  Future<void> uploadPost(File image, Map<String, dynamic> upload) async {
    sendUploadToStorage(image).then((value) {
      upload.addAll({"upload-storage-reference": value});
      sendUploadToFirestore(upload);
    });
  }

  Future<void> deletePost(String uploadUrl, String uploadId) async {
    String reference = '';

    List savedBy = [];
    await _firestore.collection('uploads').doc(uploadId).get().then((value) {
      savedBy = value.data()!['saved-by'];
      reference = value.data()!['upload-storage-reference'];
    });

    await _storage.ref(reference).delete();

    await _firestore.collection('uploads').doc(uploadId).delete();

    await _firestore.collection('users').doc(_authUser?.uid).update({
      'uploads': FieldValue.arrayRemove([uploadId])
    });

    await _firestore.collection('users').get().then((values) {
      for (final value in values.docs) {
        for (final userId in savedBy) {
          if (value.id == userId) {
            value.reference.update({
              'saves': FieldValue.arrayRemove([uploadId])
            });
          }
        }
      }
    });
  }

  Future<void> sendSavedPostToFirestore(Map<String, dynamic> data) async {
    await _firestore.collection('saves').add(data).then((value) {
      setSaveToUser(value.id);
    });
  }

  Future<String> sendUploadToStorage(File image) async {
    await _storage
        .ref(_userCollection['profile-image-reference'] + 'uploaded/')
        .child(image.path.split('/').last)
        .putFile(image);
    return _userCollection['profile-image-reference'] +
        'uploaded/' +
        image.path.split('/').last +
        '/';
  }

  Future<void> sendUploadToFirestore(Map<String, dynamic> upload) async {
    await _firestore.collection('uploads').add(upload).then((value) {
      setUploadToUser(value.id);
    });
  }

  Future<void> setUploadToUser(String id) async {
    await _firestore.collection('users').doc(_authUser?.uid).update({
      'uploads': FieldValue.arrayUnion([id])
    });
    getUploadsFromLoggedUser();
  }

  Future<void> setSaveToUser(String id) async {
    await _firestore
        .collection('users')
        .doc(_authUser?.uid)
        .get()
        .then((value) async {
      if (value['saves'] != null) {
        for (final i in value['saves']) {
          if (id == i) {
            await _firestore.collection('users').doc(_authUser?.uid).update({
              'saves': FieldValue.arrayRemove([id])
            }).whenComplete(() {
              _userCollection['saves'].removeWhere((item) => item == id);
            });
            return;
          }
        }
        await _firestore.collection('users').doc(_authUser?.uid).update({
          'saves': FieldValue.arrayUnion([id])
        }).whenComplete(() {
          _userCollection['saves'].add(id);
        });
        return;
      }
    });
    getSavedsFromLoggedUser();
  }

  bool asSaved(String uploadId) {
    if (uploadId != null) {
      for (final i in _userCollection['saves']) {
        if (i == uploadId) {
          return true;
        }
      }
    }
    return false;
  }

  Future<bool> setLikeDatabase(String id) async {
    return await _firestore
        .collection('uploads')
        .doc(id)
        .get()
        .then((value) async {
      if (value['liked-by'] != null) {
        for (final i in value['liked-by']) {
          if (_authUser?.uid == i) {
            //mecher aqui
            await _firestore.collection('uploads').doc(id).update({
              'liked-by': FieldValue.arrayRemove([_authUser?.uid])
            });
            return false;
          }
        }
        await _firestore.collection('uploads').doc(id).update({
          'liked-by': FieldValue.arrayUnion([_authUser?.uid])
        });
        return true;
      }
      return false;
    });
  }

  Future<bool> asLiked(String uploadId) async {
    await _firestore
        .collection('uploads')
        .doc(uploadId)
        .get()
        .then((value) async {
      for (final i in value['liked-by']) {
        if (_authUser?.uid == i) {
          return true;
        }
      }
    });
    return false;
  }

  Future<void> getUploadsFromLoggedUser() async {
    uploadsId = _userCollection['uploads'];
    List<Map>? listUpload = [];
    await _firestore.collection('uploads').get().then((value) {
      for (String id in uploadsId) {
        for (final upload in value.docs) {
          if (id == upload.id) {
            Map<String, dynamic> i = upload.data();
            i.addAll({'id': upload.id.toString()});
            listUpload.add(i);
          }
        }
      }
      _uploadsFromUser = listUpload;
    });
  }

  Future<List<Map<String, dynamic>>> getUploadsFromUserByListOfUploadIds(
      List uploads) async {
    List<Map<String, dynamic>>? listUpload = [];
    return await _firestore.collection('uploads').get().then((value) {
      for (String id in uploads) {
        for (final upload in value.docs) {
          if (id == upload.id) {
            Map<String, dynamic> i = upload.data();
            i.addAll({'id': upload.id.toString()});
            listUpload.add(i);
          }
        }
      }
      return listUpload;
    });
  }

  Future<void> getSavedsFromLoggedUser() async {
    savedsId = _userCollection['saves'];
    List<Map>? listSaved = [];
    await _firestore.collection('uploads').get().then((value) {
      for (String id in savedsId) {
        for (final saved in value.docs) {
          if (id == saved.id) {
            Map<String, dynamic> i = saved.data();
            i.addAll({'id': saved.id.toString()});
            listSaved.add(i);
          }
        }
      }
      _savedsFromUser = listSaved;
    });
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

  Future<void> updateUploadDescriptionById(
      String description, String id) async {
    await _firestore
        .collection('uploads')
        .doc(id)
        .update({'description': description});
  }

  Future<String> getUrlFromUploadedImage(String reference) async {
    return await _storage.ref(reference).getDownloadURL();
  }

  Future<String> getUrlFromProfileImage(String reference) async {
    return await _storage.ref(reference + 'profile').getDownloadURL();
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
    savedsId = [];
    _savedsFromUser?.clear();
  }

  Future<List> getListOfFollowerIdsByUserId(String? userId) async {
    return await _firestore.collection('users').doc(userId).get().then((value) {
      return value['followers'];
    });
  }

  Future<List<Map>> getSearchedFollowersFromUserById(
      String? userId, String query) async {
    List listOfFollowerIds = [];
    await getListOfFollowerIdsByUserId(userId).then((value) {
      listOfFollowerIds = value;
    });

    List<Map<String, dynamic>> dataOfFollowers = [];
    await _firestore.collection('users').get().then((value) async {
      for (final followerId in listOfFollowerIds) {
        for (final document in value.docs) {
          if (followerId == document.id) {
            Map<String, dynamic> map = document.data();
            if (query != null && query != '') {
              if (document.data()['username'].contains(query) ||
                  document.data()['fullname'].contains(query)) {
                await getUrlFromProfileImage(
                        document.data()['profile-image-reference'])
                    .then((value) {
                  map.addAll({'url': value});
                });
                map.addAll({'id': document.id});
                dataOfFollowers.add(map);
              }
            } else {
              await getUrlFromProfileImage(
                      document.data()['profile-image-reference'])
                  .then((value) {
                map.addAll({'url': value});
                map.addAll({'id': document.id});
              });
              dataOfFollowers.add(map);
            }
          }
        }
      }
    });
    return dataOfFollowers;
  }

  Future<void> followUserById(String? userId, String? followedId) async {
    await _firestore.collection('users').doc(userId).update({
      'followeds': FieldValue.arrayUnion([followedId])
    });

    await _firestore.collection('users').doc(followedId).update({
      'followers': FieldValue.arrayUnion([userId])
    });
  }

  Future<void> removeFollowedById(String? userId, String? followedId) async {
    await _firestore.collection('users').doc(userId).update({
      'followeds': FieldValue.arrayRemove([followedId])
    });

    await _firestore.collection('users').doc(followedId).update({
      'followers': FieldValue.arrayRemove([userId])
    });
  }

  Future<void> removeFollowerById(String? userId, String? followerId) async {
    await _firestore.collection('users').doc(userId).update({
      'followers': FieldValue.arrayRemove([followerId])
    });

    await _firestore.collection('users').doc(followerId).update({
      'followeds': FieldValue.arrayRemove([userId])
    });
  }

  Future<List> getListOfFollowedIdsByUserId(String? userId) async {
    return await _firestore.collection('users').doc(userId).get().then((value) {
      return value['followeds'];
    });
  }

  Future<List<Map>> getSearchedFollowedsFromUserById(
      String? userId, String query) async {
    List listOfFollowedIds = [];
    await getListOfFollowedIdsByUserId(userId).then((value) {
      listOfFollowedIds = value;
    });

    List<Map<String, dynamic>> dataOfFolloweds = [];
    await _firestore.collection('users').get().then((value) async {
      for (final followedId in listOfFollowedIds) {
        for (final document in value.docs) {
          if (followedId == document.id) {
            Map<String, dynamic> map = document.data();
            if (query != null && query != '') {
              if (document.data()['username'].contains(query) ||
                  document.data()['fullname'].contains(query)) {
                await getUrlFromProfileImage(
                        document.data()['profile-image-reference'])
                    .then((value) {
                  map.addAll({'url': value});
                });
                map.addAll({'id': document.id});
                dataOfFolloweds.add(map);
              }
            } else {
              await getUrlFromProfileImage(
                      document.data()['profile-image-reference'])
                  .then((value) {
                map.addAll({'url': value});
                map.addAll({'id': document.id});
              });
              dataOfFolloweds.add(map);
            }
          }
        }
      }
    });
    return dataOfFolloweds;
  }
}
