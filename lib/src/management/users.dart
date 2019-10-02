part of auth0_auth;

class Users {
  final Auth0Client client;

  Users._(this.client);

  factory Users(dynamic options) {
    assert(options['token'] != null && options['baseUrl'] != null);
    var client = Auth0Client(options['baseUrl'],
        telemetry: telemetry, token: options['token']);
    return Users._(client);
  }

  Future<Map> responseHandler(http.Response response) async {
    if (response.statusCode == 200) {
      dynamic value = jsonDecode(response.body);
      return Map.from(value);
    }
    else if (response.statusCode == 401) {
      throw Auth0Exeption(description: response.body);
    }
    throw jsonDecode(response.body);
  }

  ///Returns the user by identifier
  ///@param {Object} parameters get user by identifier parameters
  ///@param {String} parameters.id identifier of the user to obtain
  ///@returns {Promise}
  ///[ref link]: https://auth0.com/docs/api/management/v2#!/Users/get_users_by_id
  ///@memberof Users
  Future<dynamic> getUser(dynamic parameters) async {
    assert(parameters['id'] != null);
    var payload = Map.from(parameters);
    http.Response response =
        await this.client.query('/api/v2/users/${payload['id']}');
    return await responseHandler(response);
  }

  ///Patch a user's `user_metadata`
  ///@param {Object} parameters patch user metadata parameters
  ///@param {String} parameters.id identifier of the user to patch
  ///@param {Object} parameters.metadata object with attributes to store in user_metadata.
  ///@returns {Promise}
  ///[ref link]: https://auth0.com/docs/api/management/v2#!/Users/patch_users_by_id
  ///@memberof Users
  Future<dynamic> patchUser(dynamic parameters) async {
    assert(parameters['id'] != null && parameters['metadata'] != null);
    var payload = Map.from(parameters);
    http.Response response =
        await this.client.update('/api/v2/users/${payload['id']}', {
      'user_metadata': payload['metadata'],
    });
    return await responseHandler(response);
  }
}
