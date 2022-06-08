import 'package:instagram_copy/app/modules/post/post_Page.dart';
import 'package:instagram_copy/app/modules/post/post_store.dart';
import 'package:flutter_modular/flutter_modular.dart';

class PostModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.lazySingleton((i) => PostStore()),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(Modular.initialRoute, child: (_, args) => PostPage(firebase: args.data)),
  ];
}
