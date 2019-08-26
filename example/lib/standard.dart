import 'package:flutter/material.dart';
import 'package:flutter_auth0/flutter_auth0.dart';

class StandardPage extends StatefulWidget {
  final auth;
  final Function showInfo;
  const StandardPage(this.auth, this.showInfo);
  @override
  _StandardPageState createState() => _StandardPageState();
}

class _StandardPageState extends State<StandardPage> {
  bool logged;
  dynamic currentAuth;
  TextEditingController uctrl;
  TextEditingController pctrl;

  @override
  void initState() {
    super.initState();
    logged = false;
    uctrl = TextEditingController();
    pctrl = TextEditingController();
  }

  Auth0 get auth {
    return widget.auth;
  }

  Function get showInfo {
    return widget.showInfo;
  }

  void _signUp() async {
    try {
      var response = await auth.auth.createUser({
        'email': uctrl.text,
        'password': pctrl.text,
        'connection': 'Username-Password-Authentication'
      });
      showInfo('Sign Up', '''
      \nid: ${response['_id']}
      \nusername/email: ${response['email']}
      ''');
    } catch (e) {
      print(e);
    }
  }

  void _signIn() async {
    try {
      var response = await auth.auth.passwordRealm({
        'username': uctrl.text,
        'password': pctrl.text,
        'realm': 'Username-Password-Authentication'
      });
      showInfo('Sign In', '''
      \nAccess Token: ${response['access_token']}
      ''');
    } catch (e) {
      print(e);
    }
  }

  void _userInfo() async {
    try {
      var response = await auth.auth.passwordRealm({
        'username': uctrl.text,
        'password': pctrl.text,
        'realm': 'Username-Password-Authentication'
      });
      Auth0Auth authClient = Auth0Auth(
          auth.auth.clientId, auth.auth.client.baseUrl,
          bearer: response['access_token']);
      var info = await authClient.getUserInfo();
      String buffer = '';
      info.forEach((k, v) => buffer = '$buffer\n$k: $v');
      showInfo('User Info', buffer);
    } catch (e) {
      print(e);
    }
  }

  void _resetPassword() async {
    try {
      var success = await auth.auth.resetPassword({
        'email': uctrl.text,
        'connection': 'Username-Password-Authentication'
      });
      showInfo('Reset Password', 'Password Restarted: $success');
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canSignIn = (uctrl.text != null &&
        pctrl.text != null &&
        uctrl.text.isNotEmpty &&
        pctrl.text.isNotEmpty);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            enabled: !logged,
            controller: uctrl,
            decoration: const InputDecoration(
              hintText: 'Email/Username',
            ),
            onChanged: (e) {
              setState(() {});
            },
          ),
          TextField(
            enabled: !logged,
            controller: pctrl,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Password',
            ),
            onChanged: (e) {
              setState(() {});
            },
          ),
          MaterialButton(
            child: const Text('Test Sign Up'),
            color: Colors.blueAccent,
            textColor: Colors.white,
            onPressed: canSignIn ? _signUp : null,
          ),
          MaterialButton(
            child: const Text('Test Sign In'),
            color: Colors.redAccent,
            textColor: Colors.white,
            onPressed: canSignIn && !logged ? _signIn : null,
          ),
          MaterialButton(
            color: Colors.indigo,
            textColor: Colors.white,
            child: const Text('Test User Info'),
            onPressed: canSignIn ? _userInfo : null,
          ),
          MaterialButton(
            color: Colors.greenAccent,
            child: const Text('Test Reset Password'),
            onPressed: uctrl.text != null && uctrl.text.isNotEmpty
                ? _resetPassword
                : null,
          ),
        ],
      ),
    );
  }
}
