import 'package:instagram_copy/app/modules/post/post_editor/postEditor_Page.dart';
import 'package:instagram_copy/app/modules/post/post_editor/postEditor_store.dart';
import 'package:flutter_modular/flutter_modular.dart';

class PostEditorModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.lazySingleton((i) => PostEditorStore()),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(Modular.initialRoute,
        child: (_, args) => PostEditorPage(
            firebase: args.data, uploadId: args.queryParams['upload-id'])),
  ];
}
