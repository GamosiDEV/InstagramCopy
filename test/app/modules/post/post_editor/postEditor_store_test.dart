import 'package:flutter_test/flutter_test.dart';
import 'package:instagram_copy/app/modules/post/post_editor/postEditor_store.dart';
 
void main() {
  late PostEditorStore store;

  setUpAll(() {
    store = PostEditorStore();
  });

  test('increment count', () async {
    expect(store.state, equals(0));
    store.update(store.state + 1);
    expect(store.state, equals(1));
  });
}