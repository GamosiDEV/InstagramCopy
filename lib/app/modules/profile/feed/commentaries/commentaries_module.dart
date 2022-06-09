import 'package:instagram_copy/app/modules/profile/feed/commentaries/commentaries_Page.dart';
import 'package:instagram_copy/app/modules/profile/feed/commentaries/commentaries_store.dart';
import 'package:flutter_modular/flutter_modular.dart';

class CommentariesModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.lazySingleton((i) => CommentariesStore()),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(Modular.initialRoute,
        child: (_, args) => CommentariesPage(
            firebase: args.data['firebase'],
            uploadUser: args.data['upload-user'],
            uploadData: args.data['upload-data'],
            uploadDocumentId: args.data['upload-document-id'])),
  ];
}
