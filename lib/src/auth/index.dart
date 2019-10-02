part of auth0_auth;

class Auth0Auth {
  final Auth0Client client;
  final String clientId;

  Auth0Auth._(this.client, this.clientId);

  factory Auth0Auth(String clientId, String url, {dynamic bearer}) {
    assert(clientId != null);
    final _client = new Auth0Client(url, telemetry: telemetry, token: bearer);
    return Auth0Auth._(_client, clientId);
  }

  Future<dynamic> responseHandler(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    else if (response.statusCode == 401) {
      throw Auth0Exeption(description: response.body);
    }
    throw jsonDecode(response.body);
  }

  Future<Map> responseDataHandler(http.Response response) async {
    if (response.statusCode == 200) {
      dynamic value = jsonDecode(response.body);
      return Map.from(value);
    }
    else if (response.statusCode == 401) {
      throw Auth0Exeption(description: response.body);
    }
    throw jsonDecode(response.body);
  }

  //
  // Builds the full authorize endpoint url in the Authorization Server (AS) with given parameters.
  // parameters [params] to send to /authorize
  // @param {String} params.responseType type of the response to get from /authorize.
  // @param {String} params.redirectUri where the AS will redirect back after success or failure.
  // @param {String} params.state random string to prevent CSRF attacks.
  // @returns {String} authorize url with specified params to redirect to for AuthZ/AuthN.
  // [ref link]: https://auth0.com/docs/api/authentication#authorize-client
  //
  String authorizeUrl(dynamic params) {
    assert(params['redirectUri'] != null &&
        params['responseType'] != null &&
        params['state'] != null);
    var query = Map.from(params)
      ..addAll({
        'redirect_uri': params['redirectUri'],
        'response_type': params['responseType'],
        'state': params['state'],
      });
    return this.client.url(
          '/authorize',
          query: Map.from({'client_id': this.clientId})..addAll(query),
          includeTelemetry: true,
        );
  }

  //
  // Builds the full logout endpoint url in the Authorization Server (AS) with given parameters.
  // [params] to send to /v2/logout
  // @param {Boolean} [params.federated] if the logout should include removing session for federated IdP.
  // @param {String} [params.clientId] client identifier of the one requesting the logout
  // @param {String} [params.returnTo] url where the user is redirected to after logout. It must be declared in you Auth0 Dashboard
  // @returns {String} logout url with specified parameters
  // [ref link]: https://auth0.com/docs/api/authentication#logout
  //
  String logoutUrl(dynamic params) {
    var query = Map.from(params)
      ..addAll({
        'client_id': params['clientId'],
        'returnTo': params['returnTo'],
      });
    return this.client.url(
          '/v2/logout',
          query: Map.from(query),
          includeTelemetry: true,
        );
  }

  //
  // Exchanges a code obtained via /authorize (w/PKCE) for the user's tokens
  // [params] used to obtain tokens from a code
  // @param {String} params.code code returned by /authorize.
  // @param {String} params.redirectUri original redirectUri used when calling /authorize.
  // @param {String} params.verifier value used to generate the code challenge sent to /authorize.
  // @returns a Future with userInfo
  // [ref link]: https://auth0.com/docs/api-auth/grant/authorization-code-pkce
  //
  Future<Map> exchange(dynamic params) async {
    try {
      assert(params['code'] != null &&
          params['verifier'] != null &&
          params['redirectUri'] != null);
      var payload = Map.from(params)
        ..addAll({
          'code_verifier': params['verifier'],
          'redirect_uri': params['redirectUri'],
          'client_id': this.clientId,
          'grant_type': 'authorization_code',
        });
      http.Response res = await this.client.mutate('/oauth/token', payload);
      return await responseDataHandler(res);
    } catch (e) {
      throw new Auth0Exeption(description: e);
    }
  }

  //
  // Performs Auth with user credentials using the Password Realm Grant
  // [params] to send realm parameters
  // @param {String} params.username user's username or email
  // @param {String} params.password user's password
  // @param {String} params.realm name of the Realm where to Auth (or connection name)
  // @param {String} [params.audience] identifier of Resource Server (RS) to be included as audience (aud claim) of the issued access token
  // @param {String} [params.scope] scopes requested for the issued tokens. e.g. openid profile
  // @returns a Future with userInfo
  // [ref link]: https://auth0.com/docs/api-auth/grant/password#realm-support
  //
  Future<dynamic> passwordRealm(dynamic params) async {
    assert(params['username'] != null &&
        params['password'] != null &&
        params['realm'] != null);
    try {
      var payload = Map.from(params)
        ..addAll({
          'client_id': this.clientId,
          'grant_type': 'http://auth0.com/oauth/grant-type/password-realm',
        });
      http.Response res = await this.client.mutate('/oauth/token', payload);
      return await responseDataHandler(res);
    } catch (e) {
      throw new Auth0Exeption(
          name: e['name'] ?? e['error'],
          description:
              e['message'] ?? e['description'] ?? e['error_description']);
    }
  }

  //
  // Obtain new tokens using the Refresh Token obtained during Auth (requesting offline_access scope)
  // @param {Object} params refresh token params
  // @param {String} params.refreshToken user's issued refresh token
  // @param {String} [params.scope] scopes requested for the issued tokens. e.g. openid profile
  // @returns {Future}
  // [ref link]: https://auth0.com/docs/tokens/refresh-token/current#use-a-refresh-token
  //
  Future<dynamic> refreshToken(dynamic params) async {
    assert(params['refreshToken'] != null);
    try {
      var payload = Map.from(params)
        ..addAll({
          'refresh_token': params['refreshToken'],
          'client_id': this.clientId,
          'grant_type': 'refresh_token',
        });
      http.Response res = await this.client.mutate('/oauth/token', payload);
      return await responseDataHandler(res);
    } catch (e) {
      throw new Auth0Exeption(description: e);
    }
  }

  //
  // Return user information using an access token
  // @param {String} token user's access token
  // @returns {Future}
  //
  Future<dynamic> getUserInfo() async {
    try {
      http.Response res = await this.client.query('/userinfo');
      return await responseDataHandler(res);
    } catch (e) {
      throw new Auth0Exeption(description: e);
    }
  }

  //
  // Revoke an issued refresh token
  // @param {Object} params revoke token params
  // @param {String} params.refreshToken user's issued refresh token
  // @returns {Future}
  //
  dynamic revoke(dynamic params) {
    assert(params['refreshToken'] != null);
    var payload = Map.from(params)
      ..addAll({
        'token': params['refreshToken'],
        'client_id': this.clientId,
      });
    return this
        .client
        .mutate('/oauth/revoke', payload)
        .then((http.Response response) {
      if (response.statusCode == 200) {
        return {};
      }
      throw new Auth0Exeption(description: jsonDecode(response.body));
    });
  }

  //
  // Return user information using an access token
  // @param {Object} params user info params
  // @param {String} params.token user's access token
  // @returns {Future}
  //
  dynamic userInfo(dynamic params) {
    assert(params['token'] != null);
    var _client = new Auth0Client(this.client.baseUrl,
        telemetry: this.client.telemetry, token: params['token']);
    return _client.query('/userinfo').then(responseHandler);
  }

  //
  // Request an email with instructions to change password of a user
  // @param {Object} parameters reset password parameters
  // @param {String} parameters.email user's email
  // @param {String} parameters.connection name of the connection of the user
  // @returns {Future}
  //
  dynamic resetPassword(dynamic params) {
    assert(params['email'] != null && params['connection'] != null);
    var payload = Map.from(params)..addAll({'client_id': this.clientId});
    return this
        .client
        .mutate('/dbconnections/change_password', payload)
        .then((http.Response response) {
      if (response.statusCode == 200) {
        return true;
      }
      throw jsonDecode(response.body);
    });
  }

  //
  // @param {Object} params create user params
  // @param {String} params.email user's email
  // @param {String} [params.username] user's username
  // @param {String} params.password user's password
  // @param {String} params.connection name of the database connection where to create the user
  // @param {String} [params.metadata] additional user information that will be stored in user_metadata
  // @returns {Future}
  //
  Future<dynamic> createUser(dynamic params) async {
    assert(params['email'] != null &&
        params['password'] != null &&
        params['connection'] != null);
    try {
      var payload = Map.from(params)..addAll({'client_id': this.clientId});
      if (params['metadata'] != null)
        payload..addAll({'user_metadata': params['metadata']});
      http.Response res = await this.client.mutate(
            '/dbconnections/signup',
            payload,
          );
      return await responseDataHandler(res);
    } catch (e) {
      throw new Auth0Exeption(
          name: e['name'], description: e['message'] ?? e['description']);
    }
  }
}
