#import "AppDelegate.h"
#import "DemoConfig.h"
#import "LaunchSplashViewController.h"
#import "ATFOpenAdSDKDemo-Swift.h"
@import CoreLocation;
@import ATFOpenAdSDK;

@interface AppDelegate ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) LaunchSplashViewController *startupSplashViewController;
@property (nonatomic, assign) BOOL sdkInitializationSucceeded;
@property (nonatomic, assign) BOOL sdkInitializationFailed;
@property (nonatomic, assign) BOOL startupSplashLoadStarted;
@property (nonatomic, assign) BOOL startupSplashFinished;

@end

@implementation AppDelegate

- (void)attachStartupSplashViewController:(LaunchSplashViewController *)viewController {
    self.startupSplashViewController = viewController;
    if (self.sdkInitializationFailed || self.startupSplashFinished) {
        [viewController showHome];
        return;
    }
    [self startStartupSplashIfReady];
}

- (void)startupSplashDidFinish:(LaunchSplashViewController *)viewController {
    if (self.startupSplashViewController == viewController) {
        self.startupSplashFinished = YES;
        self.startupSplashViewController = nil;
    }
}

- (void)startStartupSplashIfReady {
    if (!self.sdkInitializationSucceeded ||
        !self.startupSplashViewController ||
        self.startupSplashLoadStarted ||
        self.startupSplashFinished) {
        return;
    }

    self.startupSplashLoadStarted = YES;
    LaunchSplashViewController *viewController = self.startupSplashViewController;
    dispatch_async(dispatch_get_main_queue(), ^{
        [viewController loadSplash];
    });
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // 请求定位权限
  [self requestLocationAuthorization];

    // 初始化 ATF Open Ad SDK
    [self initializeATFOpenAdSDK];
    return YES;
}

- (void)requestLocationAuthorization {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    } else {
        [self logLocationAuthorizationStatus:status];
    }
}

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    [self logLocationAuthorizationStatus:manager.authorizationStatus];
}

- (void)logLocationAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"📍 定位权限已授权");
            break;
        case kCLAuthorizationStatusDenied:
            NSLog(@"❌ 定位权限被拒绝");
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"⚠️ 定位权限受限");
            break;
        default:
            break;
    }
}

- (void)initializeATFOpenAdSDK {
    // 创建 SDK 配置（使用 DemoConfig 中的常量）
    ATFOAdSDKConfiguration *config = [ATFOAdSDKConfiguration sharedConfiguration];
    config.appID = DEMO_APP_ID;
    config.mediaID = DEMO_MEDIA_ID;
    config.secretKey = DEMO_SECRET_Key;
    // 如已自行获取设备标识，可按需传入（不传则由 SDK 自行采集）
//  config.customIDFA = @"your_idfa";
//  config.curID = @"custom_cur_id";
//  config.curIDVersion = @"custom_cur_version";
//  config.lastID = @"custom_last_id";
//  config.lastIDVersion = @"custom_last_version";
//  config.userID = NSUUID.UUID.UUIDString;
    [ATFOADLogSetting setATFOADOnLineLoggingEnabled: YES];
    config.environmentType = ATFOEnvironmentTypeDevelopment;
    // 初始化 SDK
    [ATFOAdSDKManager startWithCompletionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.sdkInitializationSucceeded = YES;
                [self startStartupSplashIfReady];
                NSLog(@"🚀 ATF Open Ad SDK 初始化成功！");
                NSLog(@"📋 配置信息: AppID=%@, MediaID=%@, 测试模式=%@",
                      DEMO_APP_ID, DEMO_MEDIA_ID, DEMO_TEST_MODE ? @"开启" : @"关闭");
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.sdkInitializationFailed = YES;
                [self.startupSplashViewController showHome];
                NSLog(@"❌ ATF Open Ad SDK 初始化失败：%@", error.localizedDescription);
            });
        }
    }];
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

@end
