import 'dart:ffi';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:instagram_copy/app/app_widget.dart';
import 'package:instagram_copy/app/modules/profile/profile_store.dart';
import 'package:instagram_copy/app/modules/shared/firebase_controller.dart';
import 'dart:math' as math;

class ProfilePage extends StatefulWidget {
  final String title;
  final FirebaseController firebase;

  const ProfilePage(
      {Key? key, this.title = '@username e botões', required this.firebase})
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
  int indexOfSelectedTab = 1;
  final List<String> pages = <String>[
    '/home/',
    '/profile/',
  ];
  late Future<Map?> _dataFromLoggedUser ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setUsername(widget.firebase
          .getLoggedUser()
          ?.displayName);
      _dataFromLoggedUser = reloadDataFromLoggedUser();
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
            onPressed: null, //adicionar foto
          ),
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: null, //config
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: FutureBuilder(
          future: reloadDataFromLoggedUser(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return DefaultTabController(
                length: 2,
                child: NestedScrollView(
                  headerSliverBuilder: (context, _) {
                    return [
                      SliverList(
                        delegate: SliverChildListDelegate(
                          profilePageUpperSide(context, snapshot),
                        ),
                      ),
                    ];
                  },
                  body: Column(
                      children: [
                        TabBar(
                          tabs: [
                            Tab(
                                icon: Icon(
                                  Icons.grid_on,
                                  color: Colors.grey,
                                )),
                            Tab(icon: Icon(Icons.save, color: Colors.grey)),
                          ],
                        ),
                        Expanded(
                            child: generateTabBarView(context, snapshot)
                        ),
                      ],
                    ),
                ),
              );
            }
            return Container(
              width: 200.0,
              height: 200.0,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                strokeWidth: 5.0,
              ),
            );
          },
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

  List<Widget> profilePageUpperSide(BuildContext context, snapshot) {
    return [createProfileScreen(context, snapshot)];
  }

  Widget createProfileScreen(BuildContext context, AsyncSnapshot snapshot) {
    return SingleChildScrollView(
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
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                  snapshot.data['fullname'],
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  snapshot.data['bio'],
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
                Modular.to
                    .pushNamed('/profile/editor/', arguments: widget.firebase);
              },
              child: Text(
                'Editar perfil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          //Abas para minhas fotos postadas e meus marcados
          //grid para mostrar as fotos
        ],
      ),
    );
  }

  Widget generateTabBarView(BuildContext context, AsyncSnapshot snapshot) {
    return TabBarView(
      children: [
        GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 2.0, mainAxisSpacing: 2.0),
          itemCount: 20,
          itemBuilder: (context, index) {
            return SizedBox(
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                        .withOpacity(1.0)),
              ),
            );
          },
        ),
        GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 2.0, mainAxisSpacing: 2.0),
          itemCount: 7,
          itemBuilder: (context, index) {
            return SizedBox(
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color:
                    Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                        .withOpacity(1.0)),
              ),
            );
          },
        ),
      ],
    );
  }

  void setUsername(String? name) {
    if (name != null) {
      setState(() {
        usernameText = name;
      });
    }
  }

  Future<Map?> reloadDataFromLoggedUser() async {
    try{

    await widget.firebase.getCollectionOfLoggedUser();
    return widget.firebase.getLoggedUserCollection();
    }catch (e){
      print(e.toString()+'-------------');
    }
  }
  void onError (String e){
    print(e);
  }

  void onBottomNavigationBarItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    screenChange();
  }

  void screenChange() {
    Modular.to.navigate(pages[_currentIndex],
        arguments: widget.firebase); //passar codigo da bottomNavigation
  }

  Widget getCurrentProfileImage() {
    String? url = widget.firebase.getProfileImageUrl();
    if (url != null && url != '') {
      return Image.network(
        url,
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
