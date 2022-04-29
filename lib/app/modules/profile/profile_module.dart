import 'package:instagram_copy/app/modules/profile/profile_Page.dart';
import 'package:instagram_copy/app/modules/profile/profile_store.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ProfileModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.lazySingleton((i) => ProfileStore()),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(Modular.initialRoute, child: (_, args) => ProfilePage()),
  ];
}
