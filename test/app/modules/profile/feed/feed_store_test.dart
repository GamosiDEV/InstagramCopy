import 'package:flutter_test/flutter_test.dart';
import 'package:instagram_copy/app/modules/profile/feed/feed_store.dart';
 
void main() {
  late FeedStore store;

  setUpAll(() {
    store = FeedStore();
  });

  test('increment count', () async {
    expect(store.state, equals(0));
    store.update(store.state + 1);
    expect(store.state, equals(1));
  });
}