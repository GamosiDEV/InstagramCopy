import 'package:instagram_copy/app/modules/profile/feed/feed_Page.dart';
import 'package:instagram_copy/app/modules/profile/feed/feed_store.dart';
import 'package:flutter_modular/flutter_modular.dart';

class FeedModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.lazySingleton((i) => FeedStore()),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(Modular.initialRoute,
        child: (_, args) => FeedPage(
            firebase: args.data,
            uploadDocumentId: args.queryParams['upload-document-id'])),
  ];
}
