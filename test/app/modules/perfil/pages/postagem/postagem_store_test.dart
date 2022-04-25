import 'package:flutter_test/flutter_test.dart';
import 'package:instagram_copy/app/modules/perfil/pages/postagem/postagem_store.dart';
 
void main() {
  late PostagemStore store;

  setUpAll(() {
    store = PostagemStore();
  });

  test('increment count', () async {
    expect(store.state, equals(0));
    store.update(store.state + 1);
    expect(store.state, equals(1));
  });
}