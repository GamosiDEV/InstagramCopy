import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:instagram_copy/app/modules/home/home_store.dart';
import 'package:flutter/material.dart';
import 'package:instagram_copy/app/modules/shared/firebase_controller.dart';

class HomePage extends StatefulWidget {
  final String title;
  final FirebaseController firebase;

  const HomePage({Key? key, this.title = 'Instacopy', required this.firebase})
      : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final HomeStore store = Modular.get();
  final List<String> pages = <String>['/home/', '/profile/'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  HomePageState() {
    print("construtor");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            child: Card(
              elevation: 0,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(5.0, 0, 10.0, 0),
                          child: ClipOval(
                            child: SizedBox.fromSize(
                              size: Size.fromRadius(16),
                              child: Image.asset(
                                'assets/images/face.jpg',
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              print("object");
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [Text('Nome'), Text('Local')],
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.share),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.65,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        alignment: FractionalOffset.center,
                        image: NetworkImage(
                            'https://images.unsplash.com/photo-1561503972-839d0c56de17?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8amFwYW4lMjBzdHJlZXQlMjB2aWV3fGVufDB8fDB8fA%3D%3D&w=1000&q=80'),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      IconButton(
                        onPressed: () {
                          print('Star');
                        },
                        icon: const Icon(Icons.star_border),
                      ),
                      IconButton(
                        onPressed: () {
                          print('Comment');
                        },
                        icon: const Icon(Icons.comment),
                      ),
                      IconButton(
                        onPressed: () {
                          print('Share');
                        },
                        icon: const Icon(Icons.share),
                      ),
                      //icone para multiplas fotos fica por aqui
                      Spacer(),
                      IconButton(
                        onPressed: null,
                        icon: const Icon(Icons.flag_outlined),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('XX curtidas'),
                        Text('Nome ' +
                            'Descrição da Imagem com maximo de 2 linhas e um botão para exibir mais'),
                        Text('Ver Todos os Comentarios'),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5.0),
                              child: ClipOval(
                                child: SizedBox.fromSize(
                                  size: Size.fromRadius(16),
                                  child: Image.asset(
                                    'assets/images/face.jpg',
                                  ),
                                ),
                              ),
                            ),
                            Text('Digite seu comentario'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(),
                ],
              ),
            ),
          );
        },
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
        .navigate(pages[_currentIndex]); //passar codigo da bottomNavigation
  }

  Future<void> onClose() async {
    await widget.firebase.signOut().then((value) {
      if (value == false) {
        Modular.to.navigate('/auth/',arguments: widget.firebase);
      }
    });
  }
}
