class Constant {
  static const String usernameConnection = 'Username-Password-Authentication';
  static const String passwordRealmGrantType =
      'http://auth0.com/oauth/grant-type/password-realm';
  // Headers
  static const Map<String, String> headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  };
  // Uris
  static String changePassword(String domain) =>
      'https://$domain/dbconnections/change_password';
  static String createUser(String domain) =>
      'https://$domain/dbconnections/signup';
  static String infoUser(String domain) =>
      'https://$domain/userinfo';
  static String passwordRealm(String domain) => 'https://$domain/oauth/token';
  static String delegation(String domain) => 'https://$domain/delegation';
}
