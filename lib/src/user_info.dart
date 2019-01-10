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
        expiresDate = DateTime.now()
            .add(Duration(milliseconds: snapshot['expires_in'] = 0)),
        tokenType = snapshot['token_type'];

  toJson() {
    return {
      'access': accessToken,
      'refresh_token': refreshToken,
      'id': idToken,
      'scope': scope,
      'expire': expiresDate,
      'type': tokenType
    };
  }
}
