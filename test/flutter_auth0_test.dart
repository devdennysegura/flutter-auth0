// import 'package:test/test.dart';
// import 'package:flutter_auth0/flutter_auth0.dart';

// Auth0 auth = new Auth0(
//     clientId: 'XIpuO0OchFaayJZRq8RvpQefOdfJkgSL',
//     domain: 'dennysegura.auth0.com');

// void main() {
//   test('sign-up', () async {
//     try {
//       dynamic user = await auth.createUser(
//           email: 'test@flutter.auth0',
//           password: '****',
//           connection: 'Username-Password-Authentication',
//           waitResponse: true);
//       expect(user['_id'], isNotNull);
//     } catch (e) {
//       print(e);
//     }
//   });
//   test('sign-in', () async {
//     Auth0User user = await auth.passwordRealm(
//         username: 'test@flutter.auth0',
//         password: '****',
//         realm: 'Username-Password-Authentication');
//     expect(user.accessToken, isNotNull);
//   });
//   test('getting delegation token', () async {
//     Auth0User user = await auth.passwordRealm(
//         username: 'test@flutter.auth0',
//         password: '****',
//         realm: 'Username-Password-Authentication');
//     String response = await auth.delegate(token: user.idToken, api: 'firebase');
//     expect(response, isNotNull);
//   });
//   test('reset password', () async {
//     try {
//       dynamic success = await auth.resetPassword(
//           email: 'test@flutter.auth0',
//           connection: 'Username-Password-Authentication');
//       expect(success, true);
//     } catch (e) {
//       print(e);
//     }
//   });
//   test('user info sucess', () async {
//     Auth0User user = await auth.passwordRealm(
//         username: 'test@flutter.auth0',
//         password: '****',
//         realm: 'Username-Password-Authentication');
//     dynamic response = await auth.userInfo(token: user.accessToken);
//     expect(response, isNotNull);
//   });
//   test('user info fail', () async {
//     dynamic user = await auth.userInfo(token: 'invalid access token');
//     expect(user, isNull);
//   });
// }
