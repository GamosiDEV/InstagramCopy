import 'package:flutter_modular/flutter_modular.dart';
import 'package:instagram_copy/app/modules/perfil/pages/postagem/comments/comments_store.dart';
import 'package:flutter/material.dart';

class CommentsPage extends StatefulWidget {
  final String title;
  const CommentsPage({Key? key, this.title = 'CommentsPage'}) : super(key: key);
  @override
  CommentsPageState createState() => CommentsPageState();
}
class CommentsPageState extends State<CommentsPage> {
  final CommentsStore store = Modular.get();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[],
      ),
    );
  }
}