#import <Flutter/Flutter.h>

@interface FlutterAuth0Plugin : NSObject<FlutterPlugin>
+ (BOOL)application:(nonnull UIApplication *)app
        openURL:(nonnull NSURL *)URL
        options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options;
@end