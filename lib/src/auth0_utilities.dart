import 'dart:io' show Platform;

String callbackUri({String bundleId, String domain}) {
  return '${bundleId.toLowerCase().replaceAll('_', '')}://$domain/${Platform.isIOS ? 'ios' : 'android'}/$bundleId/callback';
}
