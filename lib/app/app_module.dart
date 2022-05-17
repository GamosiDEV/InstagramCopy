import 'package:flutter_modular/flutter_modular.dart';
import 'package:instagram_copy/app/modules/profile/feed/feed_module.dart';

import 'modules/post/post_module.dart';
import 'modules/profile/follow/follow_module.dart';
import 'modules/profile/profile_module.dart';
import 'modules/profile/editor/editor_module.dart';
import 'modules/auth/auth_module.dart';
import 'modules/home/home_module.dart';
import 'modules/auth/sign_in/signin_module.dart';
import 'modules/intro/intro_module.dart';


class AppModule extends Module {
  @override
  final List<Bind> binds = [];

  @override
  final List<ModularRoute> routes = [//'/auth/sign_in'
    ModuleRoute(Modular.initialRoute, module: IntroModule()),
    ModuleRoute('/home/', module: HomeModule()),
    ModuleRoute('/auth/', module: AuthModule()),
    ModuleRoute('/auth/sign_in/', module: SignInModule()),
    ModuleRoute('/profile/', module: ProfileModule()),
    ModuleRoute('/profile/editor/', module: EditorModule()),
    ModuleRoute('/profile/feed', module: FeedModule()),
    ModuleRoute('/profile/follow', module: FollowModule()),
    ModuleRoute('/post/', module: PostModule()),

  ];

}