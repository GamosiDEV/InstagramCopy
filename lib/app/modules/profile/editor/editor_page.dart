import 'dart:ffi';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:instagram_copy/app/modules/profile/editor/editor_store.dart';
import 'package:flutter/material.dart';
import 'package:instagram_copy/app/modules/shared/firebase_controller.dart';

class EditorPage extends StatefulWidget {
  final String title;
  final FirebaseController firebase;

  const EditorPage(
      {Key? key, this.title = 'EditorPage', required this.firebase})
      : super(key: key);

  @override
  EditorPageState createState() => EditorPageState();
}

class EditorPageState extends State<EditorPage> {
  final EditorStore store = Modular.get();

  TextEditingController fullnameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController genereController = TextEditingController();
  TextEditingController linksController = TextEditingController();
  TextEditingController birthController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String profileImageReference = '';
  String profileImagePath = '';
  String profileImageUrl = '';
  DateTime birth = DateTime.now();

  var mounths = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro'
  ];

  Map<String, dynamic>? userData;

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
                  onPressed: () => Modular.to.pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Modular.to.pop();
                    Modular.to.pop();
                  },
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
                        child:
                            profileImagePath == null || profileImagePath == ''
                                ? getCurrentProfileImage()
                                : getProfileImageSelected()),
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
                          ..onTap = () async {
                            final image = await FilePicker.platform.pickFiles(
                              allowMultiple: false,
                              type: FileType.custom,
                              allowedExtensions: ['png', 'jpg'],
                            );

                            if (image == null) {
                              print('Imagem não selecionada ');
                              return null;
                            }

                            setProfileImage(image.files.single.path);
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
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: birth,
                        firstDate: DateTime(1850),
                        lastDate: DateTime.now(),
                      ).then((value) {
                        setState(() {
                          birth = value!;
                          setBirthDateToController();
                        });
                      });
                    },
                    readOnly: true,
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
    userData =
        widget.firebase.getLoggedUserCollection()?.cast<String, dynamic>();
    setFieldsWithLoggedUser();
  }

  void setFieldsWithLoggedUser() {
    if (userData != null) {
      setState(() {
        usernameController.text = userData?['username'];
        if (userData!['fullname'] != null)
          fullnameController.text = userData?['fullname'];
        if (userData!['genere'] != null)
          genereController.text = userData?['genere'];
        if (userData!['bio'] != null) bioController.text = userData?['bio'];
        if (userData!['links'] != null)
          linksController.text = userData?['links'];
        if (userData!['birth-date'] != null) {
          birth = userData!['birth-date'].toDate();
          setBirthDateToController();
        }

        if (userData!['profile-image-reference'] != null) {
          getUrlFromProfileImage(userData!['profile-image-reference'])
              .then((value) {
            setState(() {
              profileImageUrl = value;
            });
          });
        }
      });
    }
  }

  Future<String> getUrlFromProfileImage(String reference) async {
    return await FirebaseStorage.instance
        .ref(reference + 'profile')
        .getDownloadURL();
  }

  void saveChanges() async {
    userData?.update('username', (value) => usernameController.text);
    if (fullnameController.text != null && fullnameController.text != '')
      userData?.update('fullname', (value) => fullnameController.text);
    if (genereController.text != null && genereController.text != '')
      userData?.update('genere', (value) => genereController.text);
    if (bioController.text != null && bioController.text != '')
      userData?.update('bio', (value) => bioController.text);
    if (linksController.text != null && linksController.text != '')
      userData?.update('links', (value) => linksController.text);
    if (birthController.text != null && birthController.text != '')
      userData?.update('birth-date', (value) => Timestamp.fromDate(birth));
    if (profileImageReference != null && profileImageReference != '') {
      userData?.update(
          'profile-image-reference', (value) => profileImageReference);
      uploadSelectedImage();
    }

    widget.firebase.setCollectionOfLoggedUser(userData!);
    Modular.to.pop();
  }

  void uploadSelectedImage() async {
    try {
      widget.firebase
          .updateProfileImage(profileImageReference, profileImagePath);
    } on firebase_core.FirebaseException catch (e) {}
  }

  void setProfileImage(final path) {
    setState(() {
      profileImagePath = path;
      String? userId = widget.firebase.getLoggedUser()?.uid;
      profileImageReference = 'users/' + userId! + '/';
    });
  }

  Widget getCurrentProfileImage() {
    if (profileImageUrl != null && profileImageUrl != '') {
      return Image.network(
        profileImageUrl,
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

  Widget getProfileImageSelected() {
    return Image.file(
      new File(profileImagePath),
      fit: BoxFit.cover,
    );
  }

  void setBirthDateToController() {
    birthController.text = birth.day.toString() +
        " de " +
        mounths[birth.month - 1] +
        " de " +
        birth.year.toString();
  }
}
