import 'package:flutter_test/flutter_test.dart';
import 'package:instagram_copy/app/modules/profile/follow/follow_store.dart';
 
void main() {
  late FollowStore store;

  setUpAll(() {
    store = FollowStore();
  });

  test('increment count', () async {
    expect(store.state, equals(0));
    store.update(store.state + 1);
    expect(store.state, equals(1));
  });
}