import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:instagram_copy/app/modules/profile/feed/feed_store.dart';
import 'package:flutter/material.dart';
import 'package:instagram_copy/app/modules/shared/firebase_controller.dart';

class FeedPage extends StatefulWidget {
  final String title;
  final FirebaseController firebase;
  final String? uploadDocumentId;

  const FeedPage(
      {Key? key,
      this.title = 'FeedPage',
      required this.uploadDocumentId,
      required this.firebase})
      : super(key: key);

  @override
  FeedPageState createState() => FeedPageState();
}

class FeedPageState extends State<FeedPage> {
  final FeedStore store = Modular.get();

  @override
  void initState() {
    // TODO: implement initState
    super.initState(); WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      print(widget
          .uploadDocumentId); //pegar esse id, buscar o upload na base de dados e exibilo na tela com todas as suas informações
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          child: FutureBuilder(
            future: widget.firebase.getDocumentOfUploadedImage(widget.uploadDocumentId),
            builder: (context, snapshot) {
              if (snapshot != null && snapshot.data != null) {
                Map<String,dynamic> upload = snapshot.data as Map<String, dynamic>;
                return Card(
                  elevation: 0,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(5.0),
                        child: Row(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.fromLTRB(5.0, 0, 10.0, 0),
                              child: ClipOval(
                                child: SizedBox.fromSize(
                                  size: Size.fromRadius(16),
                                  child: getCurrentProfileImage(),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  print("Send to Profile page of the uploader");
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      widget.firebase
                                              .getLoggedUserCollection()?[
                                          'username'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                print("compartilhar imagem");
                              },
                              icon: const Icon(Icons.share),
                            ),
                          ],
                        ),
                      ),
                      setImage(upload['upload-storage-reference']),
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
                              print('Comments');
                            },
                            icon: const Icon(Icons.comment),
                          ),
                          //icone para multiplas fotos fica por aqui
                          Spacer(),
                          IconButton(
                            onPressed: (){
                                widget.firebase.setSaveToUser(widget.uploadDocumentId.toString());
                                setState(() {});
                            },
                            icon: widget.firebase.asSaved(widget.uploadDocumentId.toString()) ? Icon(Icons.save) : Icon(Icons.save_outlined),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(upload['likes'].toString()+' curtidas'),
                            Text(widget.firebase
                                .getLoggedUserCollection()?[
                            'username']+' '+upload['description']),
                            Text('Ver Comentarios'),
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
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  Widget getCurrentProfileImage() {
    String? url = widget.firebase.getProfileImageUrl();
    if (url != null && url != '') {
      return Image.network(
        url,
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

  Widget setImage(String a) {
    print(a);
    Future<String> futuro = widget.firebase.getUrlFromUploadedImage(a);
    return FutureBuilder(
      future: futuro,
        builder: (context,snapshot){
          return Container(
            height: MediaQuery.of(context).size.height * 0.65,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fitWidth,
                alignment: FractionalOffset.center,
                image: NetworkImage(snapshot.data.toString()),
              ),
            ),
          );
    });
  }
}
