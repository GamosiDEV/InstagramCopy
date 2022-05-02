import 'package:flutter_modular/flutter_modular.dart';
import 'package:instagram_copy/app/modules/profile/profile_store.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String title;

  const ProfilePage({Key? key, this.title = '@username e botões'}) : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 1;
  final ProfileStore store = Modular.get();
  final List<String> pages = <String>[
    '/home/',
    '/profile/',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: (){
              Modular.to.pushNamed('/profile/editor/');
            }, child: Text('Editar Perfil'),
          )
        ],
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


  void onBottomNavigationBarItemTapped(int index){
    setState(() {
      _currentIndex = index;
    });
    screenChange();
  }

  void screenChange(){
    Modular.to.navigate(pages[_currentIndex]);//passar codigo da bottomNavigation
  }

}
