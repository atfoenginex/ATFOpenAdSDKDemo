#import <UIKit/UIKit.h>

@class LaunchSplashViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)attachStartupSplashViewController:(LaunchSplashViewController *)viewController;
- (void)startupSplashDidFinish:(LaunchSplashViewController *)viewController;

@end
