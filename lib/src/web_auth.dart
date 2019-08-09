part of auth0_auth;

/*
 * Auth0 Auth API
 *
 * @see https://auth0.com/docs/api/authentication
 * @class Auth0
 */
class WebAuth {
  final String clientId;
  final String domain;
  final String platformName = Platform.isAndroid ? 'android' : 'ios';
  static const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/auth0');

  WebAuth({this.clientId, this.domain});

  /*
   * Starts the AuthN/AuthZ transaction against the AS in the in-app browser.
   *
   * In iOS it will use `SFSafariViewController` and in Android Chrome Custom Tabs.
   *
   * To learn more about how to customize the authorize call, check the Universal Login Page
   * article at https://auth0.com/docs/hosted-pages/login
   *
   * @param {String} state random string to prevent CSRF attacks and used to discard unexepcted results. By default its a cryptographically secure random.
   * @param {String} nonce random string to prevent replay attacks of id_tokens.
   * @param {String} audience identifier of Resource Server (RS) to be included as audience (aud claim) of the issued access token
   * @param {String} scope scopes requested for the issued tokens. e.g. `openid profile`
   * @param {String} connection The name of the identity provider to use, e.g. "google-oauth2" or "facebook". When not set, it will display Auth0's Universal Login Page.
   * @returns {Promise}
   * @see https://auth0.com/docs/api/authentication#authorize-client
   *
   * @memberof WebAuth
   */
  Future<dynamic> authorize({
    String state,
    String nonce,
    dynamic audience,
    dynamic scope,
    String connection,
  }) {
    return _channel.invokeMethod('parameters', {}).then((dynamic params) async {
      try {
        String verifier = params['verifier'];
        String codeChallenge = params['code_challenge'];
        String codeChallengeMethod = params['code_challenge_method'];
        String _state = params['state'];
        dynamic bundleIdentifier =
            await _channel.invokeMethod('bundleIdentifier');
        String redirectUri =
            '$bundleIdentifier://${this.domain}/$platformName/$bundleIdentifier/callback';
        String expectedState = state != null ? state : _state;
        String authorizeUrl =
            'https://${this.domain}/authorize?scope=$scope&audience=$audience&clientId=${this.clientId}&response_type=code&redirect_uri=$redirectUri&state=$expectedState&code_challenge_method=$codeChallengeMethod&code_challenge=$codeChallenge&client_id=${this.clientId}&auth0Client=$codeChallenge';
        String accessToken = await _channel
            .invokeMethod('showUrl', {'url': Uri.encodeFull(authorizeUrl)});
        return exchange(
            code: accessToken, refirectUri: redirectUri, verifier: verifier);
      } on PlatformException catch (e) {
        throw (e.message);
      }
    });
  }

  /*
   * Exchanges a code obtained via `/authorize` (w/PKCE) for the user's tokens
   *
   * @param {String} code code returned by `/authorize`.
   * @param {String} redirectUri original redirectUri used when calling `/authorize`.
   * @param {String} verifier value used to generate the code challenge sent to `/authorize`.
   * @see https://auth0.com/docs/api-auth/grant/authorization-code-pkce
   *
   * @memberof WebAuth
   */
  Future<dynamic> exchange({
    @required String code,
    @required String refirectUri,
    @required String verifier,
  }) async {
    try {
      http.Response response =
          await http.post(Uri.encodeFull(Constant.passwordRealm(this.domain)),
              headers: Constant.headers,
              body: jsonEncode({
                'code': code,
                'code_verifier': verifier,
                'redirect_uri': refirectUri,
                'client_id': this.clientId,
                'grant_type': 'authorization_code'
              }));
      Map<dynamic, dynamic> json = jsonDecode(response.body);
      return {
        'access_token': json['access_token'],
        'refresh_token': json['refresh_token'],
        'id_token': json['id_token'],
        'token_type': json['token_type'],
        'expires_in': json['expires_in']
      };
    } catch (e) {
      return '[Exchange WebAuthentication Error]: ${e.message}';
    }
  }

  /*
    *  Removes Auth0 session and optionally remove the Identity Provider session.
    *  In iOS it will use `SFSafariViewController`
    *
    * @param {Bool} federated Optionally remove the IdP session.
    * @returns {Promise}
    * @see https://auth0.com/docs/logout
    *
    * @memberof WebAuth
  */
  Future<void> clearSession({
    bool federated = false,
  }) async {
    try {
      dynamic bundleIdentifier =
          await _channel.invokeMethod('bundleIdentifier');
      String redirectUri =
          '$bundleIdentifier://${this.domain}/$platformName/$bundleIdentifier/callback';
      String logoutUrl = Uri.encodeFull(
          '${Constant.logout(this.domain)}?client_id=${this.clientId}&federated=$federated&returnTo=$redirectUri');
      await _channel.invokeMethod('showUrl', {'url': logoutUrl});
    } on PlatformException catch (e) {
      throw e.message;
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