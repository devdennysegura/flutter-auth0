part of auth0_auth;

class Auth0Exeption implements Exception {
  final String name;
  final String description;
  Auth0Exeption(
      {this.name = 'a0.response.invalid', this.description = 'unknown error'});

  String toString() {
    return '$name: $description';
  }
}
