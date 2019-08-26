library auth0_auth;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

part 'src/auth_exeption.dart';
part 'src/auth0_error.dart';
part 'src/user_info.dart';
part 'src/auth/index.dart';
part 'src/webauth/index.dart';
part 'src/networking/client.dart';
part 'src/networking/telemetry.dart';
part 'src/management/users.dart';

class Auth0 {
  final Auth0Auth auth;
  final WebAuth webAuth;
  final dynamic options;

  Auth0._(this.auth, this.webAuth, this.options);

  factory Auth0({String baseUrl, String clientId}) {
    assert(baseUrl != null && clientId != null);
    final auth = Auth0Auth(clientId, baseUrl);
    final webAuth = new WebAuth(auth);
    return Auth0._(auth, webAuth, {'baseUrl': baseUrl, 'clientId': clientId});
  }

  /*
   * Creates a Users API client
   * https://manage.auth0.com/#/apis/management/explorer
   * @param  {String} token for Management API
   * @return {Users}
   */
  Users users(String token) {
    return Users(Map.from(this.options)..addAll({'token': token}));
  }
}
