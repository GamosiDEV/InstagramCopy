import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:instagram_copy/app/modules/auth/sign_in/signIn_store.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  final String title;

  const SignInPage({Key? key, this.title = 'SignInPage'}) : super(key: key);

  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  final SignInStore store = Modular.get();

  @override
  Widget build(BuildContext context) {
    TextEditingController email = TextEditingController();
    TextEditingController senha = TextEditingController();
    TextEditingController username = TextEditingController();
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Testar FormField
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Cadastro de Perfil',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: email,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Digite seu Email'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                controller: senha,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Digite sua senha'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: username,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Digite seu Nome de Usuario'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  cadastroFirebase(email.text, senha.text, username.text);
                }, //enviar para o banco e retornar tela
                child: Text('Cadastrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void cadastroFirebase(String _email, String _senha, String _username) async {
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: _email, password: _senha)
        .whenComplete(() {
      Modular.to.pop();
    });
  }
}
