#import "FlutterAuth0Plugin.h"
#import <SafariServices/SafariServices.h>
#import <CommonCrypto/CommonCrypto.h>

@interface Auth0Session : NSObject
@end

@implementation Auth0Session {
  FlutterResult _flutterResult;
  SFSafariViewController *_viewController;
}
- (instancetype)initWithFlutterResult:result withController:controller{
  self = [super init];
  if (self) {
    _flutterResult = result;
    _viewController = controller;
  }
  return self;
}
- (void)getAccessToken:(NSURL *)url {
  NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
  NSArray *queryItems = urlComponents.queryItems;
  NSString *code = [self valueForKey:@"code" fromQueryItems:queryItems];
  _flutterResult(code);
  [_viewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)message:(NSString *)msg detail:(NSString *)det{
  _flutterResult([FlutterError errorWithCode:@"Error" message:msg details:det]);
}
- (NSString *)valueForKey:(NSString *)key
           fromQueryItems:(NSArray *)queryItems{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", key];
    NSURLQueryItem *queryItem = [[queryItems  filteredArrayUsingPredicate:predicate] firstObject];
    return queryItem.value;
}
@end

Auth0Session *_currentSession;

@interface FlutterAuth0Plugin () <SFSafariViewControllerDelegate>
@property (weak, nonatomic) SFSafariViewController *last;
@property (assign, nonatomic) BOOL closeOnLoad;
@end

@implementation FlutterAuth0Plugin 

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"io.flutter.plugins/auth0"
            binaryMessenger:[registrar messenger]];
  FlutterAuth0Plugin* instance = [[FlutterAuth0Plugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"authorize" isEqualToString:call.method]) {
        NSString *url = call.arguments;
        BOOL closeOnLoad = false;
        [self presentSafariWithURL:url result:result];
        self.closeOnLoad = closeOnLoad;
  } else if ([@"parameters" isEqualToString:call.method]) {
      result([self generateOAuthParameters]);
  } else if ([@"bundleIdentifier" isEqualToString:call.method]) {
      NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
      result(bundleIdentifier);
  } else {
    result(FlutterMethodNotImplemented);
  }
}
+ (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
  if (_currentSession != nil) {
        [_currentSession getAccessToken:url];
        _currentSession = nil;
    }
  return YES;
}
- (BOOL)canLaunchURL:(NSString *)urlString {
  NSURL *url = [NSURL URLWithString:urlString];
  UIApplication *application = [UIApplication sharedApplication];
  return [application canOpenURL:url];
}

#pragma mark - Internal methods
- (void)presentSafariWithURL:(NSString *)urlString result:(FlutterResult)result {
    if((BOOL)@([self canLaunchURL:urlString])){
        NSURL *url = [NSURL URLWithString:urlString];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        SFSafariViewController *controller = [[SFSafariViewController alloc] initWithURL:url];
        controller.delegate = self;
        _currentSession = [[Auth0Session alloc] initWithFlutterResult:result withController: controller];
        [[self topViewControllerWithRootViewController:window.rootViewController] presentViewController:controller animated:YES completion:nil];
        self.last = controller;
    }else{
        [_currentSession message:@"Only one Safari can be visible" detail:@"Failed to load"];
    }
}
- (void)terminateWithError:(id)error dismissing:(BOOL)dismissing animated:(BOOL)animated{
    if (dismissing) {
        [self.last.presentingViewController dismissViewControllerAnimated:animated completion:^{
            if (error) {
                [_currentSession message:error detail:nil];
            }
        }];
    } else if (error) {
        [_currentSession message:error detail:nil];
    }
    self.last = nil;
    self.closeOnLoad = NO;
}

#pragma mark - Internal methods
- (NSString *)randomValue {
    NSMutableData *data = [NSMutableData dataWithLength:32];
    int result __attribute__((unused)) = SecRandomCopyBytes(kSecRandomDefault, 32, data.mutableBytes);
    NSString *value = [[[[data base64EncodedStringWithOptions:0]
                         stringByReplacingOccurrencesOfString:@"+" withString:@"-"]
                        stringByReplacingOccurrencesOfString:@"/" withString:@"_"]
                       stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
    return value;
}
- (NSString *)sign:(NSString*)value {
    CC_SHA256_CTX ctx;

    uint8_t * hashBytes = malloc(CC_SHA256_DIGEST_LENGTH * sizeof(uint8_t));
    memset(hashBytes, 0x0, CC_SHA256_DIGEST_LENGTH);

    NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];

    CC_SHA256_Init(&ctx);
    CC_SHA256_Update(&ctx, [valueData bytes], (CC_LONG)[valueData length]);
    CC_SHA256_Final(hashBytes, &ctx);

    NSData *hash = [NSData dataWithBytes:hashBytes length:CC_SHA256_DIGEST_LENGTH];

    if (hashBytes) {
        free(hashBytes);
    }

    return [[[[hash base64EncodedStringWithOptions:0]
              stringByReplacingOccurrencesOfString:@"+" withString:@"-"]
             stringByReplacingOccurrencesOfString:@"/" withString:@"_"]
            stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
}
- (NSDictionary *)generateOAuthParameters {
    NSString *verifier = [self randomValue];
    return @{
             @"verifier": verifier,
             @"code_challenge": [self sign:verifier],
             @"code_challenge_method": @"S256",
             @"state": [self randomValue]
             };
}

#pragma mark - SFSafariViewControllerDelegate
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [_currentSession message:@"a0.session.user_cancelled" detail:@"User cancelled the Auth"];
    [controller dismissViewControllerAnimated:YES completion:nil];
}
- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    printf("safariViewController");
    if (self.closeOnLoad && didLoadSuccessfully) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    } else if (!didLoadSuccessfully) {
        [_currentSession message:@"a0.session.failed_load" detail:@"Failed to load url"];
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
}

# pragma mark - Utility
- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

@end