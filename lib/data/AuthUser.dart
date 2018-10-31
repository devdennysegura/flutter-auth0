class Auth0User {
  String accessToken;
  String idToken;
  String scope;
  DateTime expiresDate;
  String tokenType;

  Auth0User.fromMap(Map<dynamic, dynamic> snapshot)
      : accessToken = snapshot['access_token'],
        idToken = snapshot['id_token'],
        scope = snapshot['scope'],
        expiresDate = DateTime.now()
            .add(Duration(milliseconds: snapshot['expires_in'] = 0)),
        tokenType = snapshot['token_type'];

  toJson() {
    return {
      'access': accessToken,
      'id': idToken,
      'scope': scope,
      'expire': expiresDate,
      'type': tokenType
    };
  }
}
