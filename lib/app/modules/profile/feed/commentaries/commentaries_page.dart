import 'package:flutter/gestures.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:instagram_copy/app/modules/profile/feed/commentaries/commentaries_store.dart';
import 'package:flutter/material.dart';
import 'package:instagram_copy/app/modules/shared/firebase_controller.dart';

class CommentariesPage extends StatefulWidget {
  final String title;
  final Map<String, dynamic> uploadUser;
  final Map<String, dynamic> uploadData;
  final FirebaseController firebase;
  final String uploadDocumentId;

  const CommentariesPage({
    Key? key,
    this.title = 'Comentarios',
    required this.uploadUser,
    required this.uploadData,
    required this.firebase,
    required this.uploadDocumentId,
  }) : super(key: key);
  @override
  CommentariesPageState createState() => CommentariesPageState();
}

class CommentariesPageState extends State<CommentariesPage> {
  final CommentariesStore store = Modular.get();
  late Future<List<Map<String, dynamic>>> commentariesFromUpload;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    commentariesFromUpload = widget.firebase
        .getCommentariesOfUploadByListOfIds(widget.uploadData['commentaries']);
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          toProfileOfUserTappedById(
                              widget.uploadData['uploader-id']);
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage:
                              NetworkImage(widget.uploadUser['url']),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          text: TextSpan(
                            text: '',
                            children: [
                              TextSpan(
                                  text: widget.uploadUser['username'] + ': ',
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      toProfileOfUserTappedById(
                                          widget.uploadData['uploader-id']);
                                    }),
                              TextSpan(
                                text: widget.uploadData['description'],
                                style: TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                FutureBuilder(
                  future: commentariesFromUpload,
                  builder: (context, snapshot) {
                    if (snapshot != null && snapshot.hasData) {
                      print(snapshot.data);
                      return Container();
                    }
                    return progressIndicator();
                  },
                ),
              ],
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

  void toProfileOfUserTappedById(String userId) {
    print('to Modular to profile');
  }
}
