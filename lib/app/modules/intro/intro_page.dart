import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:instagram_copy/app/modules/intro/intro_store.dart';
import 'package:flutter/material.dart';
import 'package:instagram_copy/app/modules/shared/firebase_controller.dart';



class IntroPage extends StatefulWidget {
  final String title;

  const IntroPage({Key? key, this.title = 'IntroPage'}) : super(key: key);

  @override
  IntroPageState createState() => IntroPageState();
}

class IntroPageState extends State<IntroPage> {
  final IntroStore store = Modular.get();
  final FirebaseController firebase = FirebaseController();

  @override
  Widget build(BuildContext context) {

    Future.delayed(const Duration(milliseconds: 3000), () {
      setState(() {
        Modular.to.navigate('/auth/',arguments: firebase);
      });
    });

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Instacopy",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }


}
