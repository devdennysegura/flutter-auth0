part of auth0_auth;

/*
  * Return user information using an access token
  *
  * @param {String} token user's access token
  * @returns {Promise}
  *
  * @memberof Auth
*/
Future<dynamic> getUserInfo(
  String domain, {
  @required String token,
}) async {
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
  dynamic response = await http.get(
    Uri.encodeFull(
      Constant.infoUser(domain),
    ),
    headers: header,
  );
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

/*
  *
  * @param {String} email user's email
  * @param {String} connection name of the connection of the user
  * @returns {Boolean} if 
  *
*/
Future<dynamic> restorePassword(
  String clientId,
  String domain, {
  @required String email,
  @required String connection,
}) async {
  http.Response response = await http.post(
      Uri.encodeFull(Constant.changePassword(domain)),
      headers: Constant.headers,
      body: jsonEncode(
          {'client_id': clientId, 'email': email, 'connection': connection}));
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
  * @param {String} api name of target api
  * @param {String} token custom token generate by auth0 sign-in
  * @returns {String}
  *
*/
Future<String> delegateToken(
  String clientId,
  String domain, {
  @required String token,
  @required String api,
}) async {
  try {
    dynamic request =
        await http.post(Uri.encodeFull(Constant.delegation(domain)),
            headers: Constant.headers,
            body: jsonEncode({
              'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
              'id_token': token,
              'scope': 'openid',
              'client_id': clientId,
              'api_type': api,
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
  * @param {String} username user's username
  * @param {String} password user's password
  * @param {String} connection name of the database connection where to create the user
  * @param {String} metadata additional user information that will be stored in `user_metadata`
  * @param {Boolean} waitResponse control variable for wait to response or no
  * @returns {Promise}
  *
*/
Future<dynamic> newUser(
  String clientId,
  String domain, {
  @required String email,
  @required String password,
  @required String connection,
  String username,
  String metadata,
  bool waitResponse = false,
}) async {
  if (waitResponse) {
    http.Response response = await http.post(
      Uri.encodeFull(Constant.createUser(domain)),
      headers: Constant.headers,
      body: jsonEncode(
        {
          'client_id': clientId,
          'email': email,
          'password': password,
          'connection': connection,
          'username': username != null ? username : email.split('@')[0],
          'user_metadata': metadata,
        },
      ),
    );
    dynamic body = json.decode(response.body);
    if (response.statusCode == 200) {
      return body;
    } else {
      throw new Auth0Exeption(
          name: 'Sign-up user Error', description: body['description']);
    }
  } else {
    return http.post(
      Uri.encodeFull(Constant.createUser(domain)),
      headers: Constant.headers,
      body: jsonEncode({
        'client_id': clientId,
        'email': email,
        'password': password,
        'connection': connection,
        'username': username != null ? username : email.split('@')[0],
        'user_metadata': metadata,
      }),
    );
  }
}

/*
  *
  * @param {String} refreshToken user's issued refresh token
  * @returns {Promise}
  *
*/
Future<dynamic> refresh(
  String clientId,
  String domain, {
  @required String refreshToken,
}) async {
  try {
    http.Response response =
        await http.post(Uri.encodeFull(Constant.passwordRealm(domain)),
            headers: Constant.headers,
            body: jsonEncode({
              'client_id': clientId,
              'refresh_token': refreshToken,
              'grant_type': 'refresh_token'
            }));
    return jsonDecode(response.body);
  } catch (e) {
    throw new Auth0Exeption(
        name: 'Refresh Token Error', description: e.message);
  }
}
