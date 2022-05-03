import 'package:flutter_test/flutter_test.dart';
import 'package:instagram_copy/app/modules/profile/editor/editor_store.dart';
 
void main() {
  late EditorStore store;

  setUpAll(() {
    store = EditorStore();
  });

  test('increment count', () async {
    expect(store.state, equals(0));
    store.update(store.state + 1);
    expect(store.state, equals(1));
  });
}