import 'package:instagram_copy/app/modules/intro/intro_Page.dart';
import 'package:instagram_copy/app/modules/intro/intro_store.dart';
import 'package:flutter_modular/flutter_modular.dart';

class IntroModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.lazySingleton((i) => IntroStore()),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(Modular.initialRoute, child: (_, args) => IntroPage()),
  ];
}
