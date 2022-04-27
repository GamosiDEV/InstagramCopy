import 'package:instagram_copy/app/modules/auth/sign_in/signIn_Page.dart';
import 'package:instagram_copy/app/modules/auth/sign_in/signIn_store.dart';
import 'package:flutter_modular/flutter_modular.dart';

class SignInModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.lazySingleton((i) => SignInStore()),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(Modular.initialRoute, child: (_, args) => SignInPage()),
  ];
}
