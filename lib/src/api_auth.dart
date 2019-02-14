part of auth0_auth;

/*
 * Auth0 Auth API
 *
 * @see https://auth0.com/docs/api/authentication
 * @class Auth0
 */
class Auth0 {
  final String clientId;
  final String domain;

  Auth0({this.clientId, this.domain});

  /*
   * Performs Auth with user credentials using the Password Realm Grant
   *
   * @param {String} username user's username or email
   * @param {String} password user's password
   * @param {String} realm name of the Realm where to Auth (or connection name)
   * @param {String} audience identifier of Resource Server (RS) to be included as audience (aud claim) of the issued access token
   * @param {String} scope scopes requested for the issued tokens. e.g. `openid profile`
   * @returns {Auth0User}
   * @see https://auth0.com/docs/api-auth/grant/password#realm-support
   *
   * @memberof Auth
   */
  Future<Auth0User> passwordRealm({
    @required String username,
    @required String password,
    @required String realm,
    String audience,
    String scope = 'openid email profile token id id_token offline_access',
  }) async {
    http.Response response = await http.post(
      Uri.encodeFull(Constant.passwordRealm(this.domain)),
      headers: Constant.headers,
      body: jsonEncode(
        {
          'grant_type': 'http://auth0.com/oauth/grant-type/password-realm',
          'realm': realm,
          'username': username,
          'password': password,
          'audience': audience,
          'scope': scope,
          'client_id': this.clientId
        },
      ),
    );
    Map<String, dynamic> authResponse = await jsonDecode(response.body);
    if (response.statusCode == 200) {
      return Auth0User.fromMap(authResponse);
    } else {
      throw authResponse['error_description'];
    }
  }

  Future<dynamic> userInfo({
    @required String token,
  }) =>
      getUserInfo(
        this.domain,
        token: token,
      );

  Future<dynamic> resetPassword({
    @required String email,
    @required String connection,
  }) =>
      restorePassword(
        this.clientId,
        this.domain,
        email: email,
        connection: connection,
      );

  Future<String> delegate({
    @required String token,
    @required String api,
  }) =>
      delegateToken(
        this.clientId,
        this.domain,
        token: token,
        api: api,
      );

  Future<dynamic> createUser({
    @required String email,
    @required String password,
    @required String connection,
    String username,
    String metadata,
    bool waitResponse = false,
  }) =>
      newUser(
        this.clientId,
        this.domain,
        email: email,
        password: password,
        connection: connection,
        username: username,
        metadata: metadata,
        waitResponse: waitResponse,
      );

  Future<dynamic> refreshToken({
    @required String refreshToken,
  }) =>
      refresh(
        this.clientId,
        this.domain,
        refreshToken: refreshToken,
      );
}
