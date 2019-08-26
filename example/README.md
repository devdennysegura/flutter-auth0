## Installation

add `flutter_auth0: x.x.x.` to pubspec.yml file

```bash
flutter pub get
```

### Configuration

> This section is for those that want to use [Web Authentication](#web-authentication), if you dont need it just ignore this section.

#### Android

In the file `android/app/src/main/AndroidManifest.xml` you must make sure the **MainActivity** of the app has a **launchMode** value of `singleTask` and add the following activity:

```xml
<activity 
    android:name="io.flutter.plugins.flutterauth0.AuthenticationReceiver">
    <intent-filter>
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data
            android:host="YOUR_AUTH0_DOMAIN"
            android:pathPrefix="/android/${applicationId}/callback"
            android:scheme="${applicationId}" />
    </intent-filter>
</activity>
```

So if you have `dennysegura.auth0.com` as your Auth0 domain you would have the following **MainActivity**  configuration:

```xml
<activity 
    android:name="io.flutter.plugins.flutterauth0.AuthenticationReceiver">
    <intent-filter>
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data
            android:host="dennysegura.auth0.com"
            android:pathPrefix="/android/${applicationId}/callback"
            android:scheme="${applicationId}" />
    </intent-filter>
</activity>
```

#### iOS

Inside the `ios` folder find the file `AppDelegate.[swift|m]` add the following to it

```objc
#import <FlutterAuth0Plugin.h>

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
  return [FlutterAuth0Plugin application:app openURL:url options:options];
}
```

Inside the `ios` folder open the `Info.plist` and locate the values for `CFBundleIdentifier`, `CFBundleURLSchemes` and then register a URL type entry using the value of `CFBundleIdentifier` as the value of `CFBundleURLSchemes`

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>None</string>
        <key>CFBundleURLName</key>
        <string>auth0</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
        </array>
    </dict>
</array>
```

The `<string>` value should be the literal value of the Bundle Identifier with no $ variables, for example: `dennysegura.auth0.com`.

### Callback URL(s)

Callback URLs are the URLs that Auth0 invokes after the authentication process. Auth0 routes your application back to this URL and appends additional parameters to it, including a token. Since callback URLs can be manipulated, you will need to add this URL to your Application's **Allowed Callback URLs** for security. This will enable Auth0 to recognize these URLs as valid. If omitted, authentication will not be successful.

> Callback URLs must have a valid scheme value as defined by the [specification](https://tools.ietf.org/html/rfc3986#page-17). A "Redirect URI is not valid" error will raise if this format is not respected.


Go to the [Auth0 Dashboard](https://manage.auth0.com/#/applications), select your application and make sure that **Allowed Callback URLs** contains the following:

#### iOS

```text
{YOUR_BUNDLE_IDENTIFIER}://${YOUR_AUTH0_DOMAIN}/ios/{YOUR_BUNDLE_IDENTIFIER}/callback
```

#### Android

```text
{YOUR_APP_PACKAGE_NAME}://{YOUR_AUTH0_DOMAIN}/android/{YOUR_APP_PACKAGE_NAME}/callback
```

## Usage

```dart
import 'package:flutter_auth0/flutter_auth0.dart';

class ... {
Auth0 auth0;

@override
  void initState() {
    ...
    auth0 = Auth0(baseUrl: 'https://$domain/', clientId: 'auth0-client-id');
    super.initState();
  }
}
```

### Web Authentication

#### Log in

```dart
try {
    var response = await 
    auth0.
    webAuth.
        authorize({
        'audience': 'https://$domain/userinfo',
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
```

> This snippet sets the `audience` to ensure OIDC compliant responses, this can also be achieved by enabling the **OIDC Conformant** switch in your Auth0 dashboard under `Application / Settings / Advanced OAuth`. For more information please check [this documentation](https://auth0.com/docs/api-auth/intro#how-to-use-the-new-flows).

#### Log out

```dart
try {
    await auth0.
        webAuth.
            clearSession();
    webLogged = false;
    setState(() {});
} catch (e) {
    print('Error: $e');
}
```

### Authentication API

### Important: Database Connection Authentication

Since June 2017 new Clients no longer have the **Password Grant Type*** enabled by default.
If you are accessing a Database Connection using `passwordRealm` then you will need to enable the Password Grant Type, please follow [this guide](https://auth0.com/docs/clients/client-grant-types#how-to-edit-the-client-grant_types-property).

#### Login with Password Realm Grant

```dart
try {
    var response = await auth0.auth.passwordRealm({
    'username': 'info@auth0.com',
    'password': 'password',
    'realm': 'Username-Password-Authentication'
    });
    showInfo('Sign In', '''
    \nAccess Token: ${response['access_token']}
    ''');
} catch (e) {
    print(e);
}
```

#### Get user information using user's access_token

```dart
try {
    var authClient = Auth0Auth(
        auth0.auth.clientId, auth0.auth.client.baseUrl,
        bearer: 'user access_token');
    var info = await authClient.getUserInfo();
    String buffer = '';
    info.forEach((k, v) => buffer = '$buffer\n$k: $v');
    showInfo('User Info', buffer);
} catch (e) {
    print(e);
}
```

#### Getting new access token with refresh token

```dart
try {
    var response = await auth0.client.refreshToken({
    'refreshToken': 'user refresh_token',
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
```

#### Create user in database connection

```dart
try {
    var response = await auth0.auth.createUser({
        'email': 'info@auth0.com',
        'password': 'password',
        'connection': 'Username-Password-Authentication'
    });
    showInfo('Sign Up', '''
    \nid: ${response['_id']}
    \nusername/email: ${response['email']}
    ''');
} catch (e) {
    print(e);
}
```

### Management API (Users)

#### Patch user with user_metadata

```dart
try {
    var response = await auth0
        .users('user token')
        .patchUser({'id': 'user_id', 
            'metadata': {'first_name': 'John', 'last_name': 'Doe'}
        });
    print(response);
} catch (e) {
    print(e);
}
```

### Get full user profile

```dart
try {
    var response = await auth0
        .users('user token')
        .getUser({id: "user_id"});
    print(response);
} catch (e) {
    print(e);
}
```