part of auth0_auth;

const MethodChannel auth0Channel =
    const MethodChannel('io.flutter.plugins/auth0');
var platformName = Platform.isAndroid ? 'android' : 'ios';

Future<String> callbackUri(String domain) async {
  var bundleIdentifier = await auth0Channel.invokeMethod('bundleIdentifier');
  return '$bundleIdentifier://$domain/$platformName/$bundleIdentifier/callback';
}

/*
 * Helper to perform Auth against Auth0 hosted login page
 *
 * It will use `/authorize` endpoint of the Authorization Server (AS)
 * with Code Grant and Proof Key for Challenge Exchange (PKCE).
 *
 * @export
 * @class WebAuth
 * [ref link]: https://auth0.com/docs/api-auth/grant/authorization-code-pkce
 */
class WebAuth {
  final Auth0Auth client;
  final String domain;
  final String clientId;

  WebAuth(this.client)
      : this.domain = client.client.domain,
        this.clientId = client.clientId;

  /*
   * Starts the AuthN/AuthZ transaction against the AS in the in-app browser.
   *
   * In iOS it will use `SFSafariViewController` and in Android Chrome Custom Tabs.
   *
   * To learn more about how to customize the authorize call, check the Universal Login Page
   * article at https://auth0.com/docs/hosted-pages/login
   *
   * @param {Object} parameters options to send
   * @param {String} [options.audience] identifier of Resource Server (RS) to be included as audience (aud claim) of the issued access token
   * @param {String} [options.scope] scopes requested for the issued tokens. e.g. `openid profile`
   * @returns {Future}
   * [ref link]: https://auth0.com/docs/api/authentication#authorize-client
   *
   * @memberof WebAuth
   */
  Future<Map> authorize(dynamic options) async {
    return await auth0Channel
        .invokeMethod('parameters')
        .then((dynamic params) async {
      var redirectUri = await callbackUri(this.domain);
      dynamic query = Map.from(options)
        ..addAll({
          'clientId': this.clientId,
          'responseType': 'code',
          'redirectUri': redirectUri,
        })
        ..addAll(params);
      var authorizeUrl = this.client.authorizeUrl(query);
      return await auth0Channel
          .invokeMethod('authorize', authorizeUrl)
          .then((accessToken) async {
        return await this.client.exchange({
          'code': accessToken,
          'verifier': params['verifier'],
          'redirectUri': redirectUri
        });
      });
    });
  }

  /*
   *  Removes Auth0 session and optionally remove the Identity Provider session.
   *
   *  In iOS it will use `SFSafariViewController` and in Android Chrome Custom Tabs.
   *
   * @param {Object} parameters parameters to send
   * @param {Bool} federated Optionally remove the IdP session.
   * @returns {Future}
   * [ref link]: https://auth0.com/docs/logout
   *
   * @memberof WebAuth
   */
  clearSession({bool federated = false}) async {
    var payload = Map.from({
      'clientId': this.clientId,
      'returnTo': await callbackUri(this.domain)
    });

    if (federated) {
      payload['federated'] = federated.toString();
    }

    var logoutUrl = this.client.logoutUrl(payload);
    return auth0Channel.invokeMethod('authorize', logoutUrl);
  }
}
