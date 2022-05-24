import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:instagram_copy/app/modules/profile/follow/follow_store.dart';
import 'package:flutter/material.dart';
import 'package:instagram_copy/app/modules/shared/firebase_controller.dart';

class FollowPage extends StatefulWidget {
  final String title;
  final FirebaseController firebase;

  final String? userId;

  const FollowPage({
    Key? key,
    this.title = 'Instacopy',
    required this.firebase,
    required this.userId,
  }) : super(key: key);

  @override
  FollowPageState createState() => FollowPageState();
}

class FollowPageState extends State<FollowPage> {
  final FollowStore store = Modular.get();
  int _followerNumbers = 0;
  int _followedNumbers = 0;
  int totalFollowers = 0;
  int totalFolloweds = 0;

  List<Map> listOfFollowers = [];
  List<Map> listOfFolloweds = [];

  late Future<List<Map>> dataOfFollowers;
  late Future<List<Map>> dataOfFolloweds;

  TextEditingController _searchTextFromFollowersController =
      TextEditingController();
  TextEditingController _searchTextFromFollowedController =
      TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    totalFollowers =
        widget.firebase.getLoggedUserCollection()?['followers'].length;
    totalFolloweds =
        widget.firebase.getLoggedUserCollection()?['followeds'].length;
    reloadFollowers('');
    reloadFolloweds('');
  }

  void reloadFollowers(String query) {
    dataOfFollowers =
        widget.firebase.getSearchedFollowersFromUserById(widget.userId, query);
  }

  void reloadFolloweds(String query) {
    dataOfFolloweds =
        widget.firebase.getSearchedFollowedsFromUserById(widget.userId, query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                labelColor: Colors.black,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                tabs: [
                  //widget.firebase.getLoggedUserCollection()['followers'].lenght.toString()
                  Tab(
                    text: totalFollowers.toString() + ' Seguidores',
                  ),
                  Tab(
                    text: totalFolloweds.toString() + ' Seguindo',
                  )
                ],
              ),
              Expanded(child: generateTabBarView(context)),
            ],
          ),
        ),
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

  Widget generateTabBarView(BuildContext context) {
    return TabBarView(
      children: [
        FutureBuilder(
          future: dataOfFollowers,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              listOfFollowers = snapshot.data as List<Map>;
              _followerNumbers = listOfFollowers.length;
              return Container(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CupertinoSearchTextField(
                        controller: _searchTextFromFollowersController,
                        onSubmitted: (value) {
                          setState(() {
                            reloadFollowers(value);
                          });
                        },
                        onChanged: (value) {
                          if (value == null || value == '') {
                            setState(() {
                              reloadFollowers(value);
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: _followerNumbers,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              goToProfileSelected(
                                  listOfFollowers.elementAt(index));
                            },
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Container(
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: ClipOval(
                                        child: SizedBox.fromSize(
                                          size: Size.fromRadius(32),
                                          child: getCurrentProfileImage(
                                              listOfFollowers
                                                  .elementAt(index)['url']),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      //Alinhar texto a esquerda
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            listOfFollowers
                                                .elementAt(index)['username'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          // apos o nome de usuario colocar um ponto e um botão para seguir
                                          Text(listOfFollowers
                                              .elementAt(index)['fullname']),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                        onPressed: () => showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title:
                                                const Text('Remover seguidor?'),
                                            content: const Text(
                                                'O seguidor não sera informado da remoção, deseja proseguir?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  removeFollower(index);
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                  'Remover',
                                                  style: TextStyle(
                                                    color: Colors.redAccent,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        child: Text('Remover'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              );
            }
            return progressIndicator();
          },
        ),
        FutureBuilder(
          future: dataOfFolloweds,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              listOfFolloweds = snapshot.data as List<Map>;
              _followedNumbers = listOfFolloweds.length;
              return Container(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CupertinoSearchTextField(
                        controller: _searchTextFromFollowedController,
                        onSubmitted: (value) {
                          setState(() {
                            reloadFolloweds(value);
                          });
                        },
                        onChanged: (value) {
                          if (value == null || value == '') {
                            setState(() {
                              reloadFolloweds(value);
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: _followedNumbers,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              goToProfileSelected(
                                  listOfFolloweds.elementAt(index));
                            },
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Container(
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: ClipOval(
                                        child: SizedBox.fromSize(
                                          size: Size.fromRadius(32),
                                          child: getCurrentProfileImage(
                                              listOfFolloweds
                                                  .elementAt(index)['url']),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      //Alinhar texto a esquerda
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            listOfFolloweds
                                                .elementAt(index)['username'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          // apos o nome de usuario colocar um ponto e um botão para seguir
                                          Text(listOfFolloweds
                                              .elementAt(index)['fullname']),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                AlertDialog(
                                              title: const Text(
                                                  'Parar de seguir?'),
                                              content: const Text(
                                                  'Se mudar de ideia devera pedir para seguir novamente, deseja confirmar?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Cancelar'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    followUser(index);
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text(
                                                    'Deixar de seguir',
                                                    style: TextStyle(
                                                      color: Colors.redAccent,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                        child: Text('Seguindo'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              );
            }
            return progressIndicator();
          },
        )
      ],
    );
  }

  void goToProfileSelected(Map user) {
    Modular.to.pushNamed('/profile/?profileUserId=' + user['id'],
        arguments: widget.firebase);
  }

  void removeFollower(int index) {
    widget.firebase
        .removeFollowerById(
            widget.userId, listOfFollowers.elementAt(index)['id'])
        .whenComplete(() {
      setState(() {
        reloadFollowers('');
      });
    });
  }

  Widget getCurrentProfileImage(String url) {
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

  void followUser(int index) {
    widget.firebase.removeFollowedById(
        widget.userId, listOfFolloweds.elementAt(index)['id']);
    reloadFolloweds('');
  }
}
