## v1.0.0 (2018-10-31)

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