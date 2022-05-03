import 'package:flutter_test/flutter_test.dart';
import 'package:instagram_copy/app/modules/auth/sign_in/signIn_store.dart';
 
void main() {
  late SignInStore store;

  setUpAll(() {
    store = SignInStore();
  });

  test('increment count', () async {
    expect(store.state, equals(0));
    store.update(store.state + 1);
    expect(store.state, equals(1));
  });
}