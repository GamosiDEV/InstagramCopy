import 'package:instagram_copy/app/modules/profile/editor/editor_Page.dart';
import 'package:instagram_copy/app/modules/profile/editor/editor_store.dart';
import 'package:flutter_modular/flutter_modular.dart';

class EditorModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.lazySingleton((i) => EditorStore()),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(Modular.initialRoute, child: (_, args) => EditorPage()),
  ];
}
