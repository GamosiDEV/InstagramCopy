import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:instagram_copy/app/modules/profile/feed/feed_store.dart';
import 'package:flutter/material.dart';
import 'package:instagram_copy/app/modules/shared/firebase_controller.dart';
import 'package:flutter_share/flutter_share.dart';

class FeedPage extends StatefulWidget {
  final String title;
  final FirebaseController firebase;
  final String? uploadDocumentId;
  final String? userId;

  const FeedPage(
      {Key? key,
      this.title = 'Publicações',
      required this.uploadDocumentId,
      required this.userId, //remover isto
      required this.firebase})
      : super(key: key);

  @override
  FeedPageState createState() => FeedPageState();
}

class FeedPageState extends State<FeedPage> {
  final FeedStore store = Modular.get();
  bool asSaved = false;
  bool asLiked = false;
  Map<String, dynamic> uploadUser = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      asSaved = widget.firebase.asSaved(widget.uploadDocumentId.toString());
      asLiked = widget.firebase.asLiked(widget.uploadDocumentId.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: GestureDetector(
            child: FutureBuilder(
              future: widget.firebase
                  .getDocumentOfUploadedImage(widget.uploadDocumentId),
              builder: (context, snapshot) {
                if (snapshot != null && snapshot.data != null) {
                  Map<String, dynamic> upload =
                      snapshot.data as Map<String, dynamic>;
                  return Card(
                    elevation: 0,
                    child: FutureBuilder(
                      future: widget.firebase
                          .getCollectionOfUserById(upload['uploader-id']),
                      builder: (context, snapshotFromUser) {
                        if (snapshotFromUser.hasData) {
                          uploadUser =
                              snapshotFromUser.data as Map<String, dynamic>;
                          return Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(5.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          5.0, 0, 10.0, 0),
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
                                          Modular.to.pushNamed(
                                              '/profile/?profileUserId=' +
                                                  upload['uploader-id'],
                                              arguments: widget.firebase);
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              uploadUser['username'].toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    upload['uploader-id'] ==
                                            widget.firebase.getAuthUser()?.uid
                                        ? DropdownButton(
                                            icon: Icon(Icons.more_vert_sharp),
                                            onChanged: (String? newValue) {
                                              switch (newValue) {
                                                case 'Editar':
                                                  Modular.to.pushNamed(
                                                      '/post/editor/?upload-id=' +
                                                          widget
                                                              .uploadDocumentId
                                                              .toString(),
                                                      arguments:
                                                          widget.firebase);
                                                  break;
                                                case 'Excluir':
                                                  widget.firebase.deletePost(
                                                      uploadUser['url'],
                                                      widget.uploadDocumentId
                                                          .toString());
                                                  Modular.to.pop();
                                                  break;
                                              }
                                            },
                                            items: <String>['Editar', 'Excluir']
                                                .map<DropdownMenuItem<String>>(
                                              (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              },
                                            ).toList(),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                              setImage(upload['upload-storage-reference']),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      await widget.firebase
                                          .setLikeDatabase(widget
                                              .uploadDocumentId
                                              .toString())
                                          .then((value) {
                                        setState(() {
                                          asLiked = value;
                                        });
                                      });
                                    },
                                    icon: asLiked
                                        ? Icon(Icons.star)
                                        : Icon(Icons.star_border),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      print('Comments');
                                    },
                                    icon: const Icon(Icons.comment),
                                  ),
                                  IconButton(
                                    onPressed: () => showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        title: const Text(
                                            'Baixando e compartilhando'),
                                        content: const Text(
                                            'Deseja baixar a imagem e compartilha-la em seguida?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                                context, 'Cancelar'),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, 'OK');
                                            },
                                            child: const Text('OK'),
                                          )
                                        ],
                                      ),
                                    ).then(
                                      (value) {
                                        if (value == 'OK') {
                                          downloadAndShare(upload);
                                          Modular.to.pop();
                                        }
                                        ;
                                      },
                                    ),
                                    icon: const Icon(Icons.share),
                                  ),
                                  //icone para multiplas fotos fica por aqui
                                  Spacer(),
                                  IconButton(
                                    onPressed: () async {
                                      await widget.firebase.setSaveToUser(
                                          widget.uploadDocumentId.toString());
                                      setState(() {
                                        asSaved = widget.firebase.asSaved(
                                            widget.uploadDocumentId.toString());
                                      });
                                    },
                                    icon: asSaved
                                        ? Icon(Icons.save)
                                        : Icon(Icons.save_outlined),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(upload['liked-by'].length.toString() +
                                        ' curtidas'),
                                    Text(uploadUser['username'].toString() +
                                        ' ' +
                                        upload['description'].toString()),
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
                          );
                        }
                        return progressIndicator();
                      },
                    ),
                  );
                }
                return progressIndicator();
              },
            ),
          ),
        ),
      ),
    );
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

  Widget getCurrentProfileImage() {
    String? url = uploadUser['url'];
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
    Future<String> futuro = widget.firebase.getUrlFromUploadedImage(a);
    return FutureBuilder(
        future: futuro,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
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
          }
          return progressIndicator();
        });
  }

  void downloadAndShare(Map<String, dynamic> data) {
    widget.firebase
        .getUrlFromUploadedImage(data['upload-storage-reference'])
        .then((value) {
      print(value);
      FlutterShare.share(title: 'Olha Isso', linkUrl: value);
    });
  }
}
