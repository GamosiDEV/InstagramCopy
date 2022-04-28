
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
  late final FirebaseAuth auth ;

  @override
  void initState() {
    auth = FirebaseAuth.instance;
    asLoged();
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    TextEditingController email = TextEditingController();
    TextEditingController senha = TextEditingController();
    GlobalKey<FormState> formKey = GlobalKey<FormState>();



    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: Form(
          key: formKey,
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
                    style: ElevatedButton.styleFrom(primary: Colors.lightBlueAccent),
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
                          Modular.to.pushNamed('/auth/sign_in/');
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
      ),
    );
  }

  void asLoged() async{
    if(await auth.currentUser != null){
      Modular.to.navigate('/home/');
    }
  }

  void signInFirebase(String _email, String _senha) async{
    try {
       await auth.signInWithEmailAndPassword(
          email: _email,
          password: _senha
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    } finally {
      final user = auth.currentUser;
      if(user != null) {
        final email = user.email;
        print("logado :  " + email!);
      }
    }


    await auth.authStateChanges()
        .listen((User? user) {
          if(user == null) {
            print('User is currently signed out!');
          }else{
            print('User is signed in!');
            Modular.to.navigate('/home/');
          }
    });

  }

}
