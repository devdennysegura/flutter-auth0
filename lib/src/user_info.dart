part of auth0_auth;

class Auth0User {
  String accessToken;
  String refreshToken;
  String idToken;
  String scope;
  DateTime expiresDate;
  String tokenType;

  Auth0User.fromMap(Map<dynamic, dynamic> snapshot)
      : accessToken = snapshot['access_token'],
        refreshToken = snapshot['refresh_token'],
        idToken = snapshot['id_token'],
        scope = snapshot['scope'],
        expiresDate =
            DateTime.now().add(Duration(seconds: snapshot['expires_in'] = 0)),
        tokenType = snapshot['token_type'];

  toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'id_token': idToken,
      'scope': scope,
      'expires_in': expiresDate,
      'token_type': tokenType
    };
  }
}
