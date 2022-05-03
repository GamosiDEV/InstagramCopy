import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:instagram_copy/app/modules/profile/editor/editor_store.dart';
import 'package:flutter/material.dart';

class EditorPage extends StatefulWidget {
  final String title;

  const EditorPage({Key? key, this.title = 'EditorPage'}) : super(key: key);

  @override
  EditorPageState createState() => EditorPageState();
}

class EditorPageState extends State<EditorPage> {
  final EditorStore store = Modular.get();
  final _auth = FirebaseAuth.instance;
  //late final loggedUser;

  TextEditingController fullnameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController genereController = TextEditingController();
  TextEditingController linksController = TextEditingController();
  TextEditingController birthController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(
      (timeStamp) {
        getLoggedUser();
        //setFieldsWithLoggedUser();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          alignment: Alignment.centerLeft,
          icon: Icon(Icons.close),
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Alterações não salvas'),
              content: const Text(
                  'As alterações feitas em seu perfil não seram salvas, deseja realmente sair ?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                )
              ],
            ),
          ).then(
            (value) {
              if (value == 'OK') Modular.to.pop();
            },
          ),
        ),
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            color: Colors.lightBlue,
            alignment: Alignment.centerRight,
            icon: Icon(Icons.check),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                saveChanges();
                //salvar infos no database, retornar ao perfil
              }
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipOval(
                    child: SizedBox.fromSize(
                      size: Size.fromRadius(48),
                      child: Image.network(
                        'https://previews.123rf.com/images/happyvector071/happyvector0711904/happyvector071190414608/120957993-creative-illustration-of-default-avatar-profile-placeholder-isolated-on-background-art-design-grey-p.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: 'Alterar imagem de Perfil',
                        style: TextStyle(fontSize: 16, color: Colors.lightBlue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            print(
                                'Executar comandos para alterar foto de perfil');
                          }),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) return 'Insira um nome';
                    },
                    controller: fullnameController,
                    decoration: InputDecoration(
                      labelText: 'Nome Completo',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) return 'Insira um nome de usuario';
                    },
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Nome de Usuario',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: genereController,
                    //Feminino/Masculino/Personalizado/Não informar
                    decoration: InputDecoration(
                      labelText: 'Genero',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: bioController,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: linksController,
                    decoration: InputDecoration(
                      labelText: 'Links',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: birthController,
                    decoration: InputDecoration(
                      labelText:
                          'Data de Nascimento', //Exibir sim ou não e escolher data caso sim
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getLoggedUser() {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .then((value) {
          setFieldsWithLoggedUser(value.data());
        });
      }
    });
  }

  void setFieldsWithLoggedUser(Map? user) {
    if (user != null) {
      setState(() {
        usernameController.text = user['username'];
        if(user['fullname'] != null)
          fullnameController.text = user['fullname'];
        if(user['genere'] != null)
          genereController.text = user['genere'];
        if(user['bio'] != null)
          bioController.text = user['bio'];
        if(user['links'] != null)
          linksController.text = user['links'];
        if(user['birth-date'] != null)
          birthController.text = user['birth-date'];
        //set image with stored image
      });
    }
  }

  void saveChanges() async {
    Map<String, dynamic> map = {
      "username": usernameController.text,
    };
    if(fullnameController.text != null && fullnameController.text != '')
      map.addAll({'fullname': fullnameController.text});
    if(genereController.text != null && genereController.text != '')
      map.addAll({'genere': genereController.text});
    if(bioController.text != null && bioController.text != '')
      map.addAll({'bio': bioController.text});
    if(linksController.text != null && linksController.text != '')
      map.addAll({'links': linksController.text});
    if(birthController.text != null && birthController.text != '')
      map.addAll({'birth-date': birthController.text});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .set(map).whenComplete(() => Modular.to.pop());
  }
}
