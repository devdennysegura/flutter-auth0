part of auth0_auth;

class AuthExeption implements Exception {
  final String name;
  final String description;
  AuthExeption(
      {this.name = 'a0.response.invalid', this.description = 'unknown error'});
}
