import 'package:flutter_modular/flutter_modular.dart';
import 'package:modular_test/modular_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instagram_copy/app/modules/auth/sig_in/sigIn_module.dart';
 
void main() {

  setUpAll(() {
    initModule(SigInModule());
  });
}