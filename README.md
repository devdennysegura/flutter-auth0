# flutter_auth0

A Flutter plugin to use the [Auth0 API](https://auth0.com/docs/api/authentication).

Note: This plugin is still under development, and some APIs might not be available yet. Feedback and Pull Requests are most welcome!

## Usage
To use this plugin, add `flutter_auth0` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## SignIn with email and password

To signin instance auth0 using `auth0-client-id` and `auth0-domain` and call signInWithEmailAndPassword function with email and password as params

```dart

final auth = new Auth0(clientId: 'your-client-id', domain: 'your-domain');

Auth0User user = await auth.passwordRealm(
        username: 'username/email',
        password: 'password',
        realm: 'Username-Password-Authentication');
```

## Example

See the [example application](https://github.com/devdennysegura/flutter-auth0/tree/master/example) source
for a complete sample app using the auth0 authentication.

## What is Auth0?

Auth0 helps you to:

* Add authentication with [multiple authentication sources](https://docs.auth0.com/identityproviders), either social like **Google, Facebook, Microsoft Account, LinkedIn, GitHub, Twitter, Box, Salesforce, amont others**, or enterprise identity systems like **Windows Azure AD, Google Apps, Active Directory, ADFS or any SAML Identity Provider**.
* Add authentication through more traditional **[username/password databases](https://docs.auth0.com/mysql-connection-tutorial)**.
* Add support for **[linking different user accounts](https://docs.auth0.com/link-accounts)** with the same user.
* Support for generating signed [Json Web Tokens](https://docs.auth0.com/jwt) to call your APIs and **flow the user identity** securely.
* Analytics of how, when and where users are logging in.
* Pull data from other sources and add it to the user profile, through [JavaScript rules](https://docs.auth0.com/rules).

## Create a free Auth0 Account

1. Go to [Auth0](https://auth0.com) and click Sign Up.
2. Use Google, GitHub or Microsoft Account to login.

## Issue Reporting

If you have found a bug or if you have a feature request, please report them at this repository issues section. Please do not report security vulnerabilities on the public GitHub issue tracker. The [Responsible Disclosure Program](https://auth0.com/whitehat) details the procedure for disclosing security issues.

## Author

Denny Segura <dev.dennysegura@gmail.com>

this readme based on [react-native-auth0](https://github.com/auth0/react-native-auth0)

## License

This project is licensed under the MIT license. See the [LICENSE](LICENSE.txt) file for more info.