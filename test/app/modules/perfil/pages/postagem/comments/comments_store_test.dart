import 'package:flutter_test/flutter_test.dart';
import 'package:instagram_copy/app/modules/perfil/pages/postagem/comments/comments_store.dart';
 
void main() {
  late CommentsStore store;

  setUpAll(() {
    store = CommentsStore();
  });

  test('increment count', () async {
    expect(store.state, equals(0));
    store.update(store.state + 1);
    expect(store.state, equals(1));
  });
}