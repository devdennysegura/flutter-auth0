import 'package:flutter/material.dart';
import 'package:flutter_auth0/flutter_auth0.dart';

class PKCEPage extends StatefulWidget {
  final auth;
  final Function showInfo;
  const PKCEPage(this.auth, this.showInfo);
  @override
  _PKCEPageState createState() => _PKCEPageState();
}

class _PKCEPageState extends State<PKCEPage> {
  bool webLogged;
  dynamic currentWebAuth;

  @override
  void initState() {
    super.initState();
    webLogged = false;
  }

  Auth0 get auth {
    return widget.auth;
  }

  Function get showInfo {
    return widget.showInfo;
  }

  void webLogin() async {
    try {
      var response = await auth.webAuth.authorize({
        'audience': 'https://${auth.auth.client.domain}/userinfo',
        'scope': 'openid email offline_access',
      });
      DateTime now = DateTime.now();
      showInfo('Web Login', '''
      \ntoken_type: ${response['token_type']}
      \nexpires_in: ${DateTime.fromMillisecondsSinceEpoch(response['expires_in'] + now.millisecondsSinceEpoch)}
      \nrefreshToken: ${response['refresh_token']}
      \naccess_token: ${response['access_token']}
      ''');
      webLogged = true;
      currentWebAuth = Map.from(response);
      setState(() {});
    } catch (e) {
      print('Error: $e');
    }
  }

  void webRefreshToken() async {
    try {
      var response = await auth.webAuth.client.refreshToken({
        'refreshToken': currentWebAuth['refresh_token'],
      });
      DateTime now = DateTime.now();
      showInfo('Refresh Token', '''
      \ntoken_type: ${response['token_type']}
      \nexpires_in: ${DateTime.fromMillisecondsSinceEpoch(response['expires_in'] + now.millisecondsSinceEpoch)}
      \naccess_token: ${response['access_token']}
      ''');
    } catch (e) {
      print('Error: $e');
    }
  }

  void closeSessions() async {
    try {
      await auth.webAuth.clearSession();
      webLogged = false;
      setState(() {});
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MaterialButton(
            color: Colors.lightBlueAccent,
            textColor: Colors.white,
            child: const Text('Test Login'),
            onPressed: !webLogged ? webLogin : null,
          ),
          MaterialButton(
            color: Colors.blueAccent,
            textColor: Colors.white,
            child: const Text('Test Refresh Token'),
            onPressed: webLogged ? webRefreshToken : null,
          ),
          MaterialButton(
            color: Colors.redAccent,
            textColor: Colors.white,
            child: const Text('Test Clear Sessions'),
            onPressed: webLogged ? closeSessions : null,
          ),
        ],
      ),
    );
  }
}
