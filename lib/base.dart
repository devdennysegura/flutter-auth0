import 'dart:async';

abstract class Auth0Interface {
  Future<dynamic> signInWithEmailAndPassword(String email, String password);
  Future<String> getDelegationToken(String idToken, String api);
  Future<void> recoveryPassword(String email);
}
