import 'package:instagram_copy/app/modules/profile/follow/follow_Page.dart';
import 'package:instagram_copy/app/modules/profile/follow/follow_store.dart';
import 'package:flutter_modular/flutter_modular.dart';

class FollowModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.lazySingleton((i) => FollowStore()),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(Modular.initialRoute, child: (_, args) => FollowPage(firebase: args.data)),
  ];
}
