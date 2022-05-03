import 'package:flutter_test/flutter_test.dart';
import 'package:instagram_copy/app/modules/auth/sig_in/sigIn_store.dart';
 
void main() {
  late SigInStore store;

  setUpAll(() {
    store = SigInStore();
  });

  test('increment count', () async {
    expect(store.state, equals(0));
    store.update(store.state + 1);
    expect(store.state, equals(1));
  });
}