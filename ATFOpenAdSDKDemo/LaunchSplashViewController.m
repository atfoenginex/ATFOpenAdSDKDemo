#import "LaunchSplashViewController.h"
#import "AppDelegate.h"
#import "DemoConfig.h"
#import "ViewController.h"
@import ATFOpenAdSDK;

@interface LaunchSplashViewController () <ATFOAdSplashDelegate>

@property (nonatomic, strong) ATFOSplashAd *splashAd;
@property (nonatomic, assign) BOOL loadStarted;
@property (nonatomic, assign) BOOL finished;

@end

@implementation LaunchSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
}

- (void)loadSplash {
    if (self.loadStarted || self.finished) {
        return;
    }
    self.loadStarted = YES;

    ATFOAdSlot *adSlot = [[ATFOAdSlot alloc] init];
    adSlot.slotID = DEMO_SPLASH_SLOT_ID;
    adSlot.adSize = CGSizeMake(DEMO_SPLASH_WIDTH, DEMO_SPLASH_HEIGHT - 120);
    adSlot.AdType = ATFOpenSDKAdTypeSplash;

    self.splashAd = [[ATFOSplashAd alloc] initWithSlot:adSlot];
    self.splashAd.delegate = self;
    self.splashAd.customBottomView = UIView.new;
    self.splashAd.rootViewController = self;
    [self.splashAd loadAdData];
}

- (void)showHome {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showHome];
        });
        return;
    }
    if (self.finished) {
        return;
    }
    self.finished = YES;

    self.splashAd.delegate = nil;
    self.splashAd = nil;

    UINavigationController *navigationController = self.navigationController;
    if (navigationController) {
        [navigationController setViewControllers:@[ViewController.new] animated:NO];
    }
    AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
    [appDelegate startupSplashDidFinish:self];
}

#pragma mark - ATFOAdSplashDelegate

- (void)atfo_splashLoadedBy:(ATFOSplashAd *)splashAd with:(ATFOAdInfo *)adInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.finished) {
            return;
        }
        [splashAd showSplashInRootViewController:self];
    });
}

- (void)atfo_splashLoadFailedBy:(ATFOSplashAd *)splashAd with:(NSError *)error {
    NSLog(@"❌ 启动开屏加载失败：%@", error.localizedDescription);
    [self showHome];
}

- (void)atfo_splashShowFailedBy:(ATFOSplashAd *)splashAd with:(NSError *)error {
    NSLog(@"❌ 启动开屏展示失败：%@", error.localizedDescription);
    [self showHome];
}

- (void)atfo_splashCloseBy:(ATFOSplashAd *)splashAd {
    [self showHome];
}

@end
