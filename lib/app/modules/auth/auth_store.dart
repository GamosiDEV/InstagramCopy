import 'package:flutter_triple/flutter_triple.dart';

class AuthStore extends NotifierStore<Exception, int> {

  AuthStore() : super(0);

  void signInFirebase(String _email, String _senha) async{}

}