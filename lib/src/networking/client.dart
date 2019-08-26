part of auth0_auth;

class Auth0Client {
  final String protocol;
  final String domain;
  final dynamic telemetry;
  final String bearer;
  final String baseUrl;

  Auth0Client.fromClient(Auth0Client client, {String bearer})
      : protocol = client.protocol,
        domain = client.domain,
        telemetry = client.telemetry,
        bearer = client.bearer ?? bearer,
        baseUrl = client.baseUrl;

  Auth0Client._(
      this.protocol, this.domain, this.telemetry, this.bearer, this.baseUrl);

  factory Auth0Client(String baseUrl, {dynamic telemetry, dynamic token}) {
    assert(baseUrl != null);
    var parsed = Uri.parse(baseUrl);
    final String scheme = parsed.scheme;
    final String host = parsed.host;
    final String authorization = token != null ? 'Bearer $token' : null;
    return Auth0Client._(scheme, host, telemetry, authorization, baseUrl);
  }

  Future<http.Response> mutate(String path, dynamic body) async {
    return this.request('POST', url(path), body: body);
  }

  Future<http.Response> update(String path, dynamic body) async {
    return this.request('PATCH', url(path), body: body);
  }

  Future<http.Response> query(String path, {dynamic params}) async {
    return this.request('GET', url(path, query: params));
  }

  String url(String path, {dynamic query, bool includeTelemetry = false}) {
    dynamic params = query ?? {};
    if (includeTelemetry) {
      params['auth0Client'] = this.encodedTelemetry();
    }
    var parsed = Uri(
      scheme: protocol,
      host: domain,
      path: path,
      queryParameters: Map.from(params),
    );
    return parsed.query.isEmpty
        ? parsed.toString().replaceAll('?', '')
        : parsed.toString();
  }

  Future<http.Response> request(String method, String url,
      {dynamic body, dynamic headers}) async {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Auth0-Client': this.encodedTelemetry()
    };
    if (bearer != null) {
      headers['Authorization'] = this.bearer;
    }
    var _client = new http.Client();
    Map<String, Future<http.Response>> handler = {
      'POST': _client.post(url, body: Map.from((body ?? {}))),
      'GET': _client.get(url, headers: headers),
      'PATCH': _client.patch(url, body: Map.from((body ?? {}))),
    };
    http.Response uriResponse;
    try {
      uriResponse = await handler[method];
    } catch (e) {
      print(e);
    } finally {
      _client.close();
    }
    return uriResponse;
  }

  String encodedTelemetry() {
    return base64.encode(utf8.encode(jsonEncode(telemetry)));
  }
}
