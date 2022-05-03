import 'package:instagram_copy/app/modules/auth/auth_Page.dart';
import 'package:instagram_copy/app/modules/auth/auth_store.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:instagram_copy/app/modules/auth/sign_in/signIn_page.dart';

class AuthModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.lazySingleton((i) => AuthStore()),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(Modular.initialRoute, child: (_, args) => AuthPage()),
  ];
}
