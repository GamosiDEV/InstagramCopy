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
  final String? profileUserId;

  const ProfilePage({
    Key? key,
    this.title = '@username e botões',
    required this.profileUserId,
    required this.firebase,
  }) : super(key: key);

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
  int _postNumber = 0;
  int _savedNumber = 0;
  int _followerNumbers = 0;
  int _followedNumbers = 0;
  final List<String> pages = <String>[
    '/home/',
    '/profile/',
  ];

  Map<String, dynamic> user = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.firebase
        .getCollectionOfUserById(widget.profileUserId.toString()).then((value){
          setState(() {
            usernameText = value['username'];
          });
    });

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {});
  }

  void _refresh() {
    _postNumber = user['uploads'].length;
    _savedNumber = user['saves'].length;

  }

  @override
  Widget build(BuildContext context) {
    print(widget.profileUserId);
    return Scaffold(
      appBar: AppBar(
        title: Text(usernameText),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_rounded),
            onPressed: () async {
              await Modular.to
                  .pushNamed('/post/', arguments: widget.firebase)
                  .then((value) {
                setState(() {
                  _refresh();
                });
              });
            }, //adicionar foto
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
          future: widget.firebase
              .getCollectionOfUserById(widget.profileUserId.toString()),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              user = snapshot.data as Map<String, dynamic>;

              print(usernameText);
              _refresh();
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
                      Expanded(child: generateTabBarView(context, snapshot)),
                    ],
                  ),
                ),
              );
            }
            return progressIndicator();
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

  Widget progressIndicator() {
    return Container(
      width: 200.0,
      height: 200.0,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        strokeWidth: 5.0,
      ),
    );
  }

  List<Widget> profilePageUpperSide(BuildContext context, snapshot) {
    return [createProfileScreen(context, snapshot)];
  }

  Widget createProfileScreen(BuildContext context, AsyncSnapshot snapshot) {
    _followerNumbers = user['followers'].length;
    _followedNumbers = user['followeds'].length;
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
                      _postNumber.toString(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const Text('Publicações')
                  ],
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  Modular.to
                      .pushNamed(
                    '/profile/follow/?userId=' +
                        widget.profileUserId.toString(),
                    arguments: widget.firebase,
                  )
                      .whenComplete(() {
                    print('execução ao retornar da pagina de seguidores');
                  });
                },
                child: SizedBox(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _followerNumbers.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const Text('Seguidores')
                      ],
                    ),
                  ),
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  //enviar um sinalizador para abrir diretamente na aba de seguido
                  Modular.to
                      .pushNamed(
                          '/profile/follow/?userId=' +
                              widget.firebase.getAuthUser()!.uid,
                          arguments: widget.firebase)
                      .whenComplete(() {
                    print('execução ao retornar da pagina de seguidores');
                  });
                },
                child: SizedBox(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _followedNumbers.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const Text('Seguindo')
                      ],
                    ),
                  ),
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
                  user['fullname'] != null ? user['fullname'] : '',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user['bio'] != null ? user['bio'] : '',
                  style: TextStyle(fontSize: 16),
                )
              ],
            ),
          ),
          widget.profileUserId == widget.firebase.getAuthUser()?.uid ? Container(
            padding: EdgeInsets.all(8.0),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await Modular.to
                    .pushNamed('/profile/editor/', arguments: widget.firebase)
                    .then((value) {
                  _refresh();
                });
              },
              child: Text(
                'Editar perfil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ) : Container(
            //botão para seguir vai aqui=====================================================================================
          ),
        ],
      ),
    );
  }

  Widget generateTabBarView(BuildContext context, AsyncSnapshot snapshot) {
    // List<Map<String, dynamic>>? userUploads = [];
    //
    //     .then((value) {
    //         userUploads = value;
    //         print(userUploads);
    // });
    return TabBarView(
      children: [
        FutureBuilder(
            future: widget.firebase
                .getUploadsFromUserByListOfUploadIds(user['uploads']),
            builder: (context, snapshot) {
              List<Map<String, dynamic>>? userUploads =
                  snapshot.data as List<Map<String, dynamic>>?;
              return GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2.0,
                    mainAxisSpacing: 2.0),
                itemCount: _postNumber,
                itemBuilder: (context, index) {
                  if (userUploads != null) {
                    userUploads.sort((m1, m2) => m2["upload-date-time"]
                        .compareTo(m1["upload-date-time"]));
                    _postNumber = userUploads.length;
                    if (index < userUploads.length) {
                      Future<String> futuro = widget.firebase
                          .getUrlFromUploadedImage(userUploads
                              .elementAt(index)['upload-storage-reference']);
                      return FutureBuilder(
                        future: futuro,
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            return GestureDetector(
                              child: SizedBox(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.fitWidth,
                                      alignment: FractionalOffset.center,
                                      image: NetworkImage(
                                          snapshot.data.toString()),
                                    ),
                                  ),
                                ),
                              ),
                              behavior: HitTestBehavior.opaque,
                              onTap: () async {
                                String uploadId =
                                    userUploads.elementAt(index)['id'];
                                await Modular.to
                                    .pushNamed(
                                  '/profile/feed/?upload-document-id=' +
                                      uploadId,
                                  arguments: widget.firebase,
                                )
                                    .then((value) {
                                  _refresh();
                                });
                              },
                            );
                          }
                          return progressIndicator();
                        },
                      );
                    }
                  }
                  return progressIndicator();
                },
              );
            }),
        FutureBuilder(
          future: widget.firebase
              .getUploadsFromUserByListOfUploadIds(user['saves']),
          builder: (context, snapshot) {
            List<Map<String, dynamic>>? userSaveds =
                snapshot.data as List<Map<String, dynamic>>?;
            return GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2.0,
                  mainAxisSpacing: 2.0),
              itemCount: _savedNumber,
              itemBuilder: (context, index) {
                if (userSaveds != null) {
                  userSaveds.sort((m1, m2) =>
                      m2["upload-date-time"].compareTo(m1["upload-date-time"]));
                  _savedNumber = userSaveds.length;
                  if (index < userSaveds.length) {
                    Future<String> futuro = widget.firebase
                        .getUrlFromUploadedImage(userSaveds
                            .elementAt(index)['upload-storage-reference']);
                    return FutureBuilder(
                      future: futuro,
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          return GestureDetector(
                            child: SizedBox(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.fitWidth,
                                    alignment: FractionalOffset.center,
                                    image:
                                        NetworkImage(snapshot.data.toString()),
                                  ),
                                ),
                              ),
                            ),
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              //print('/profile/feed/?uploadDocumentId='+userUploads.elementAt(index)['id']);
                              await Modular.to
                                  .pushNamed(
                                '/profile/feed/?upload-document-id=' +
                                    userSaveds.elementAt(index)['id'],
                                arguments: widget.firebase,
                              )
                                  .then((value) {
                                print('vortei');
                                setState(() {
                                  _savedNumber = widget.firebase
                                      .getSavedsFromUser()!
                                      .length;
                                });
                              });
                            },
                          );
                        }
                        return progressIndicator();
                      },
                    );
                  }
                }
                return progressIndicator();
              },
            );
          },
        ),
      ],
    );
  }

  NetworkImage showUploadedImage(Map map) {
    String url = '';
    widget.firebase
        .getUrlFromUploadedImage(map['profile-image-reference'])
        .then((value) {
      if (value != null) {
        url = value;
      }
    });

    return NetworkImage(url);
  }

  void setUsername(String? name) {
    if (name != null) {
        usernameText = name;
    }
  }

  Future<Map?> reloadDataFromLoggedUser() async {
    try {
      await widget.firebase.getCollectionOfLoggedUser();
      return widget.firebase.getLoggedUserCollection();
    } catch (e) {
      print(e.toString() + '- reloadDataFromLoggedUser()');
    }
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
