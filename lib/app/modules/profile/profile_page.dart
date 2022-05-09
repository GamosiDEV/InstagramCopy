import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:instagram_copy/app/modules/profile/profile_store.dart';
import 'package:instagram_copy/app/modules/shared/firebase_controller.dart';

class ProfilePage extends StatefulWidget {
  final String title;
  final FirebaseController firebase;

  const ProfilePage({Key? key, this.title = '@username e botões', required this.firebase})
      : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 1;
  final ProfileStore store = Modular.get();
  String fullNameText = '';
  String bioText = '';
  String usernameText = '';
  String profileImageUrl = '';
  final List<String> pages = <String>[
    '/home/',
    '/profile/',
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      getLoggedUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(usernameText),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_rounded),
            onPressed: null,//adicionar foto
          ),
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: null,//config
          ),
        ],
      ),
      body: Container(
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor),
            label: 'Perfil',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: onBottomNavigationBarItemTapped,
      ),
    );
  }

  void onBottomNavigationBarItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    screenChange();
  }

  void screenChange() {
    Modular.to
        .navigate(pages[_currentIndex],arguments: widget.firebase); //passar codigo da bottomNavigation
  }

  void getLoggedUserData(){
    Map<String, dynamic>? userData = widget.firebase.getLoggedUserCollection();
    if(userData != null){
      setDataFromLoggedUser(userData);
    }
  }

  void setDataFromLoggedUser(Map userData){
    setState(() {
      fullNameText = userData['fullname'];
      bioText = userData['bio'];
      usernameText = userData['username'];
      print('===================================');
      print(userData['profile-image-reference']);
      getUrlFromProfileImage(userData['profile-image-reference']);
    });
  }

  // void getUserDataFromFirebase() async {
  //   await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(_auth.currentUser?.uid)
  //       .get()
  //       .then((value) {
  //     setState(() {
  //       fullNameText = value.get('fullname');
  //       bioText = value.get('bio');
  //       usernameText = value.get('username');
  //       getUrlFromProfileImage(value.get('profile-image-reference'));
  //     });
  //   });
  // }

  void getUrlFromProfileImage(String reference) async {
    await FirebaseStorage.instance
        .ref(reference + 'profile')
        .getDownloadURL().then((value){
          setState(() {
            profileImageUrl = value;
          });
    });
  }

  Widget getCurrentProfileImage() {
    if (profileImageUrl != null && profileImageUrl != '') {
      return Image.network(
        profileImageUrl,
        fit: BoxFit.cover,
      );
    } else {
      return getPlaceholder();
    }
  }

  Widget getPlaceholder() {
    return Image.network(
      'https://previews.123rf.com/images/happyvector071/happyvector0711904/happyvector071190414608/120957993-creative-illustration-of-default-avatar-profile-placeholder-isolated-on-background-art-design-grey-p.jpg',
      fit: BoxFit.cover,
    );
  }
}
