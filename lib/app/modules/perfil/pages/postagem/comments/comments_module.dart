import 'package:instagram_copy/app/modules/perfil/pages/postagem/comments/comments_Page.dart';
import 'package:instagram_copy/app/modules/perfil/pages/postagem/comments/comments_store.dart';
import 'package:flutter_modular/flutter_modular.dart';

class CommentsModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.lazySingleton((i) => CommentsStore()),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(Modular.initialRoute, child: (_, args) => CommentsPage()),
  ];
}
