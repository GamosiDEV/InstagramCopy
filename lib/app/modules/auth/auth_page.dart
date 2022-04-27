
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:instagram_copy/app/modules/auth/auth_store.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  final String title;

  const AuthPage({Key? key, this.title = 'AuthPage'}) : super(key: key);

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  final AuthStore store = Modular.get();

  @override
  Widget build(BuildContext context) {
    TextEditingController email = TextEditingController();
    TextEditingController senha = TextEditingController();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text(
                "InstaCopy",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 5.0),
              child: TextField(
                controller: email,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Digite seu Email',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
              child: TextField(
                controller: senha,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Digite sua Senha',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: (){
                    signInFirebase(email.text,senha.text);
                },
                  child: Text('Entrar'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Clique',
                  style: TextStyle(fontSize: 16,color: Colors.black),
                  children: [
                    TextSpan(
                      text: ' aqui ',
                      style: TextStyle(fontSize: 16,color: Colors.lightBlue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                        Modular.to.pushNamed('/auth/sign_in');
                        }
                    ),
                    TextSpan(
                        text: 'para criar a sua conta agora',
                        style: TextStyle(fontSize: 16,color: Colors.black),
                    ),
                  ]
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void signInFirebase(String _email, String _senha) async{
    bool asLoged = false;
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email,
          password: _senha
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }

    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
          if(user == null) {
            print('User is currently signed out!');
          }else{
            print('User is signed in!');
            Modular.to.navigate('/home');
          }
    });

  }

}
