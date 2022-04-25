import 'package:flutter_modular/flutter_modular.dart';
import 'package:instagram_copy/app/modules/perfil/pages/postagem/postagem_store.dart';
import 'package:flutter/material.dart';

class PostagemPage extends StatefulWidget {
  final String title;
  const PostagemPage({Key? key, this.title = 'PostagemPage'}) : super(key: key);
  @override
  PostagemPageState createState() => PostagemPageState();
}
class PostagemPageState extends State<PostagemPage> {
  final PostagemStore store = Modular.get();

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