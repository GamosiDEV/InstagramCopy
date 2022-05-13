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
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      print(widget.uploadDocumentId);//pegar esse id, buscar o upload na base de dados e exibilo na tela com todas as suas informações
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
          child: Card(
            elevation: 0,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(5.0, 0, 10.0, 0),
                        child: ClipOval(
                          child: SizedBox.fromSize(
                            size: Size.fromRadius(16),
                            child: Image.asset(
                              'assets/images/face.jpg',
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            print("object");
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [Text('Nome'), Text('Local')],
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      alignment: FractionalOffset.center,
                      image: NetworkImage(
                          'https://images.unsplash.com/photo-1561503972-839d0c56de17?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8amFwYW4lMjBzdHJlZXQlMjB2aWV3fGVufDB8fDB8fA%3D%3D&w=1000&q=80'),
                    ),
                  ),
                ),
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
                        print('Comment');
                      },
                      icon: const Icon(Icons.comment),
                    ),
                    IconButton(
                      onPressed: () {
                        print('Share');
                      },
                      icon: const Icon(Icons.share),
                    ),
                    //icone para multiplas fotos fica por aqui
                    Spacer(),
                    IconButton(
                      onPressed: null,
                      icon: const Icon(Icons.flag_outlined),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('XX curtidas'),
                      Text('Nome ' +
                          'Descrição da Imagem com maximo de 2 linhas e um botão para exibir mais'),
                      Text('Ver Todos os Comentarios'),
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
          ),
        ),
      ),
    );
  }
}
