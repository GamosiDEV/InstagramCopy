import 'package:instagram_copy/app/modules/perfil/pages/postagem/postagem_Page.dart';
import 'package:instagram_copy/app/modules/perfil/pages/postagem/postagem_store.dart';
import 'package:flutter_modular/flutter_modular.dart';

class PostagemModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.lazySingleton((i) => PostagemStore()),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(Modular.initialRoute, child: (_, args) => PostagemPage()),
  ];
}
