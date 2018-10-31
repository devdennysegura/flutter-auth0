import 'dart:async';
import 'dart:convert';
import 'package:flutter_auth0/data/AuthUser.dart';
import 'package:flutter_auth0/utils/auth0.dart';
import 'package:flutter_auth0/utils/auth0Error.dart';
import 'package:http/http.dart' as http;

import 'package:meta/meta.dart';

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
  Future<Auth0User> passwordRealm(
      {@required String username,
      @required String password,
      @required String realm,
      String audience,
      String scope = 'openid email profile token id id_token'}) async {
    dynamic request =
        await http.post(Uri.encodeFull(Constant.passwordRealm(this.domain)),
            headers: Constant.headers,
            body: jsonEncode({
              'grant_type': 'http://auth0.com/oauth/grant-type/password-realm',
              'realm': realm,
              'username': username,
              'password': password,
              'audience': audience,
              'scope': scope,
              'client_id': this.clientId
            }));
    Map<String, dynamic> response = await jsonDecode(request.body);
    return Auth0User.fromMap(response);
  }

  /*
   *
   * @param {String} refreshToken user's issued refresh token
   * @returns {Promise}
   *
   */
  Future<void> refreshToken({@required String refreshToken}) async {
    return http
        .post(Uri.encodeFull(Constant.changePassword(this.domain)),
            headers: Constant.headers,
            body: jsonEncode({
              'client_id': this.clientId,
              'refresh_token': refreshToken,
              'grant_type': 'refresh_token'
            }))
        .catchError((error) {
      throw new Auth0Exeption(
          name: 'Refresh Token Error', description: error.message);
    });
  }

  /*
   * @param {String} api name of target api
   * @param {String} token custom token generate by auth0 sign-in
   * @returns {String}
   *
   */
  Future<String> delegate(
      {@required String token, @required String api}) async {
    try {
      dynamic request =
          await http.post(Uri.encodeFull(Constant.delegation(this.domain)),
              headers: Constant.headers,
              body: jsonEncode({
                'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'id_token': token,
                'scope': 'openid',
                'client_id': this.clientId,
                'api_type': api
              }));
      Map<dynamic, dynamic> response = jsonDecode(request.body);
      return response['id_token'];
    } catch (e) {
      return '[Delegation Request Error]: ${e.message}';
    }
  }

  /*
   *
   * @param {String} email user's email
   * @param {String} connection name of the connection of the user
   * @returns {Boolean} if 
   *
   */
  Future<dynamic> resetPassword(
      {@required String email, @required String connection}) async {
    http.Response response = await http.post(
        Uri.encodeFull(Constant.changePassword(this.domain)),
        headers: Constant.headers,
        body: jsonEncode({
          'client_id': this.clientId,
          'email': email,
          'connection': connection
        }));
    dynamic _body =
        response.statusCode == 200 ? response.body : json.decode(response.body);
    if (response.statusCode == 200) {
      return _body
          .contains('We\'ve just sent you an email to reset your password');
    } else {
      throw new Auth0Exeption(
          name: 'User Reset Password Error',
          description:
              _body['error'] != null ? _body['error'] : _body['description']);
    }
  }

  /*
   *
   * @param {String} email user's email
   * @param {String} username user's username
   * @param {String} password user's password
   * @param {String} connection name of the database connection where to create the user
   * @param {String} metadata additional user information that will be stored in `user_metadata`
   * @param {Boolean} waitResponse control variable for wait to response or no
   * @returns {Promise}
   *
   */
  Future<dynamic> createUser(
      {@required String email,
      @required String password,
      @required String connection,
      String username,
      String metadata,
      bool waitResponse = false}) async {
    dynamic body = {
      'client_id': this.clientId,
      'email': email,
      'password': password,
      'connection': connection,
      'username': username != null ? username : email.split('@')[0],
      'user_metadata': metadata
    };
    if (waitResponse) {
      http.Response response = await http.post(
          Uri.encodeFull(Constant.createUser(this.domain)),
          headers: Constant.headers,
          body: jsonEncode(body));
      dynamic _body = json.decode(response.body);
      if (response.statusCode == 200) {
        return _body;
      } else {
        throw new Auth0Exeption(
            name: 'Sign-up user Error', description: _body['description']);
      }
    } else {
      return http.post(Uri.encodeFull(Constant.createUser(this.domain)),
          headers: Constant.headers, body: jsonEncode(body));
    }
  }

  /*
   * Return user information using an access token
   *
   * @param {String} token user's access token
   * @returns {Promise}
   *
   * @memberof Auth
   */
  Future<dynamic> userInfo({@required String token}) async {
    List<String> claims = [
      'sub',
      'name',
      'given_name',
      'family_name',
      'middle_name',
      'nickname',
      'preferred_username',
      'profile',
      'picture',
      'website',
      'email',
      'email_verified',
      'gender',
      'birthdate',
      'zoneinfo',
      'locale',
      'phone_number',
      'phone_number_verified',
      'address',
      'updated_at'
    ];
    Map<String, String> header = {'Authorization': 'Bearer $token'};
    header.addAll(Constant.headers);
    dynamic response = await http
        .get(Uri.encodeFull(Constant.infoUser(this.domain)), headers: header);
    try {
      Map<dynamic, dynamic> userInfo = Map();
      dynamic body = json.decode(response.body);
      claims.forEach((claim) {
        userInfo[claim] = body[claim];
      });
      return userInfo;
    } catch (e) {
      return null;
    }
  }
}
