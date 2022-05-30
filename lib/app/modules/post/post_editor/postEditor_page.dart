import 'package:file_picker/file_picker.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:instagram_copy/app/modules/post/post_editor/postEditor_store.dart';
import 'package:flutter/material.dart';
import 'package:instagram_copy/app/modules/shared/firebase_controller.dart';
import 'package:transparent_image/transparent_image.dart';

class PostEditorPage extends StatefulWidget {
  final String title;
  final FirebaseController firebase;
  final String? uploadId;

  const PostEditorPage(
      {Key? key,
      this.title = 'Editar postagem',
      required this.firebase,
      required this.uploadId})
      : super(key: key);
  @override
  PostEditorPageState createState() => PostEditorPageState();
}

class PostEditorPageState extends State<PostEditorPage> {
  final PostEditorStore store = Modular.get();
  Future<Map<String, dynamic>>? uploadedImageData;
  final _formKey = GlobalKey<FormState>();
  final _text = TextEditingController();
  String? _selectedFilePath;

  @override
  void initState() {
    super.initState();
    uploadedImageData =
        widget.firebase.getDocumentOfUploadedImage(widget.uploadId.toString());

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            alignment: Alignment.centerLeft,
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Modular.to.pop();
            },
          ),
          title: Text(widget.title),
          actions: [
            IconButton(
              color: Colors.lightBlue,
              icon: Icon(Icons.check),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.firebase
                      .updateUploadDescriptionById(
                          _text.text, widget.uploadId.toString())
                      .whenComplete(() => print('updated!'));
                }
                Modular.to.pop();
              },
            ),
          ],
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.topCenter,
          child: FutureBuilder(
            future: uploadedImageData,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot != null) {
                Map upload = snapshot.data as Map;
                _text.text = upload['description'];

                Future<String>? futureUrl = widget.firebase
                    .getUrlFromUploadedImage(
                        upload['upload-storage-reference']);
                print(_text.text);
                return ListView(
                  children: [
                    FutureBuilder(
                      future: futureUrl,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot != null) {
                          String? url = snapshot.data as String;
                          return SizedBox(
                            height: 400,
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.fitWidth,
                                  alignment: FractionalOffset.center,
                                  image: NetworkImage(url.toString()),
                                ),
                              ),
                            ),
                          );
                        }
                        return progressIndicator();
                      },
                    ),
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
                );
              }
              return progressIndicator();
            },
          ),
        ));
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
}
