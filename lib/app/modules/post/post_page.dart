import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:instagram_copy/app/modules/post/post_store.dart';
import 'package:flutter/material.dart';
import 'package:instagram_copy/app/modules/shared/firebase_controller.dart';
import 'package:transparent_image/transparent_image.dart';

class PostPage extends StatefulWidget {
  final String title;
  final FirebaseController firebase;

  const PostPage(
      {Key? key, this.title = 'Nova Publicação', required this.firebase})
      : super(key: key);

  @override
  PostPageState createState() => PostPageState();
}

class PostPageState extends State<PostPage> {
  final PostStore store = Modular.get();

  final _formKey = GlobalKey<FormState>();
  final _text = TextEditingController();
  String? _selectedFilePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            alignment: Alignment.centerLeft,
            icon: Icon(Icons.close),
            onPressed: () {
              Modular.to.pop();
            }),
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            color: Colors.lightBlue,
            alignment: Alignment.centerRight,
            icon: Icon(Icons.arrow_forward),
            onPressed: () async{
              if (_selectedFilePath != null &&
                  _selectedFilePath != '' &&
                  _formKey.currentState!.validate()) {
                Map<String, dynamic> upload = {
                  "description": _text.text,
                  "liked-by": [],
                  "commentaries": [],
                  "upload-date-time": DateTime.now(),
                  "uploader-id": widget.firebase.getAuthUser()?.uid
                };
                print(upload['description']);
                  await widget.firebase
                      .uploadPost(File(_selectedFilePath!), upload)
                      .then((value) {
                    print("completado 51");
                  });
                Modular.to.pop(true);
              }
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.topCenter,
        child: ListView(
          children: [
            InkWell(
                onTap: selectImage,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: (_selectedFilePath != null)
                      ? FadeInImage(
                          fit: BoxFit.contain,
                          placeholder: MemoryImage(kTransparentImage),
                          // verificar e arrumar
                          image: Image.file(File(_selectedFilePath!)).image,
                        )
                      : SizedBox(
                          height: 400,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  colors: [
                                    Color(0xFFFFB344),
                                    Color(0xFFE60064),
                                  ]),
                            ),
                            height: 300,
                            child: const Center(
                              child: Text(
                                'Aperte para selecionar uma imagem',
                                style: TextStyle(
                                  color: Color(0xFFFAFAFA),
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                )),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _text,
                  decoration: const InputDecoration(
                    hintText: 'Digite uma descrição para imagem',
                    border: InputBorder.none,
                  ),
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Caption is empty';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> selectImage() async {
    final image = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg'],
    );

    if (image == null) {
      print('Imagem não selecionada ');
      return null;
    }
    setImagePath(image.files.single.path);
    setState(() {});
  }

  void setImagePath(String? path) {
    _selectedFilePath = path;
  }
}
