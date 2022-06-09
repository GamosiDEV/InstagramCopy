import 'package:flutter_test/flutter_test.dart';
import 'package:instagram_copy/app/modules/profile/feed/commentaries/commentaries_store.dart';
 
void main() {
  late CommentariesStore store;

  setUpAll(() {
    store = CommentariesStore();
  });

  test('increment count', () async {
    expect(store.state, equals(0));
    store.update(store.state + 1);
    expect(store.state, equals(1));
  });
}