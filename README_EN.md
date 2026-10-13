[简体中文](README.md) ｜ **English**

# ATFOpenAdSDK iOS Demo

iOS sample project and integration guide for ATFOpenAdSDK. This repository contains both a runnable demo app and the full integration guide.

---

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Requirements](#2-requirements)
- [3. Quick Start](#3-quick-start)
- [4. Integrating Into Your App](#4-integrating-into-your-app)
- [5. SDK Initialization](#5-sdk-initialization)
- [6. Loading Ads](#6-loading-ads)
- [7. Permissions and Info.plist](#7-permissions-and-infoplist)
- [8. Logging and Debugging](#8-logging-and-debugging)
- [9. Error Handling](#9-error-handling)
- [10. FAQ](#10-faq)

---

## 1. Introduction

ATFOpenAdSDK is ATF's iOS advertising SDK. It supports splash, interstitial, rewarded video and feed ads, and can aggregate multiple third-party ad sources through adapters.

This repository provides:

- A runnable demo project: `ATFOpenAdSDKDemo.xcworkspace`
- Sample code for every ad format under `ATFOpenAdSDKDemo/`
- A single configuration file for demo parameters: `ATFOpenAdSDKDemo/DemoConfig.h`

The demo covers the following ad formats:

| Ad format | Entry point | Notes |
| --- | --- | --- |
| Splash | `SplashViewController` | Full-screen splash with optional bottom view and skip |
| Interstitial | `InterstitialViewController` | Full-screen interstitial |
| Rewarded video | `RewardViewController` | Playback and reward callbacks |
| Feed (template) | `FeedViewController` | Rendered by the SDK template |
| Feed (self-rendering) | `FeedViewSelfRenderController` | Custom view built by the publisher |
| Feed (ATF express) | `FeedViewATFExpressController` | Rendered by the server template |

> The demo also includes a custom User-Agent setting, an environment switch, ad validity checks and an on-screen log panel.

## 2. Requirements

| Item | Requirement |
| --- | --- |
| Xcode | 15 or later |
| iOS | 15.0 or later |
| CocoaPods | 1.13 or later |
| Languages | Objective-C and Swift (the demo mixes both) |

## 3. Quick Start

```bash
# 1. Clone the repository
git clone git@github.com:atfoenginex/ATFOpenAdSDKDemo.git
cd ATFOpenAdSDKDemo

# 2. Replace the demo credentials (see below)
#    Edit ATFOpenAdSDKDemo/DemoConfig.h and replace every YOUR_* placeholder

# 3. Install dependencies
pod install

# 4. Open the workspace and run
open ATFOpenAdSDKDemo.xcworkspace
```

**Step 2 is mandatory.** `DemoConfig.h` only contains placeholder constants in this repository. Until you replace them, the SDK cannot initialize and ad requests will not be filled.

Constants to replace in `ATFOpenAdSDKDemo/DemoConfig.h`:

| Constant | Description |
| --- | --- |
| `DEMO_APP_ID` | SDK App ID |
| `DEMO_MEDIA_ID` | SDK Media ID |
| `DEMO_SECRET_Key` | SDK Secret Key |
| `DEMO_SPLASH_SLOT_ID` | Splash slot ID |
| `DEMO_INTERSTITIAL_SLOT_ID` | Interstitial slot ID |
| `DEMO_REWARD_SLOT_ID` | Rewarded video slot ID |
| `DEMO_FEED_SLOT_ID` | Feed slot ID |
| `DEMO_FEED_SELFRENDER_SLOT_ID` | Self-rendering feed slot ID |
| `DEMO_FEED_ATFEXPRESS_SLOT_ID` | ATF express feed slot ID |

## 4. Integrating Into Your App

### 4.1 Podfile

Dependencies are published in the public spec repository [atfoenginex/atfo-specs](https://github.com/atfoenginex/atfo-specs).

```ruby
source 'https://cdn.cocoapods.org/'
source 'https://github.com/atfoenginex/atfo-specs.git'

platform :ios, '15.0'
use_frameworks! :linkage => :static

target 'YourApp' do
  # ATF ad SDK core
  pod 'ATFOpenAdSDK', '1.3.1.0'

  # Third-party ad adapters (add only what you need)
  pod 'ATFOBaiduAdapter', '1.3.0.0'
  pod 'ATFOBeiZiAdapter', '1.2.1.0'
  pod 'ATFOGDTAdapter', '1.3.1.0'
  pod 'ATFOGroMoreAdapter', '1.3.0.0'
  pod 'ATFOMeiShuAdapter', '1.2.1.0'
  pod 'ATFONoahAdapter', '1.2.0.0'
  pod 'ATFONoahAdapter/UTDID', '1.2.0.0'
  pod 'ATFOQuMengAdapter', '1.3.0.0'
  pod 'ATFOSigmobAdapter', '1.3.0.0'
  pod 'ATFOYoukuAdapter', '1.2.0.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
      config.build_settings['VALID_ARCHS'] = 'arm64'
      config.build_settings['OTHER_SWIFT_FLAGS'] = '$(inherited) -package-name atfopensdk'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
    if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
      target.build_configurations.each do |config|
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
    end
  end
end
```

Then run:

```bash
pod install
```

### 4.2 Importing the SDK

Objective-C:

```objc
@import ATFOpenAdSDK;
// or
#import <ATFOpenAdSDK/ATFOpenAdSDK.h>
```

Swift:

```swift
import ATFOpenAdSDK
```

## 5. SDK Initialization

Initialize the SDK in `application:didFinishLaunchingWithOptions:`.

```objc
ATFOAdSDKConfiguration *config = [ATFOAdSDKConfiguration sharedConfiguration];
config.appID = @"YOUR_APP_ID";
config.mediaID = @"YOUR_MEDIA_ID";
config.secretKey = @"YOUR_SECRET_KEY";

// Development prints more integration logs; switch to ATFOEnvironmentProduction before release
config.environmentType = ATFOEnvironmentDevelopment;
[ATFOADLogSetting setATFOADOnLineLoggingEnabled:YES];

// Pass device identifiers only if you collect them yourself (otherwise the SDK handles it)
// config.customIDFA = @"your_idfa";
// config.curID = @"custom_cur_id";
// config.curIDVersion = @"custom_cur_version";
// config.lastID = @"custom_last_id";
// config.lastIDVersion = @"custom_last_version";

// Business user identifier, used for tracking and reward verification
// config.userID = @"your_user_id";

// Custom User-Agent (optional)
// config.customUserAgent = @"your_user_agent";

[ATFOAdSDKManager startWithCompletionHandler:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        NSLog(@"ATF Open Ad SDK initialized");
    } else {
        NSLog(@"ATF Open Ad SDK init failed: %@", error.localizedDescription);
    }
}];
```

Common `ATFOAdSDKManager` APIs:

| API | Description |
| --- | --- |
| `+ startWithCompletionHandler:` | Initialize the SDK; ads can only be requested afterwards |
| `+ isInitialized` | Whether the SDK has been initialized |
| `+ getAvailableAdapterNames` | Names of the currently registered adapters |
| `+ clearLocalConfigs` | Clear locally cached configuration |

## 6. Loading Ads

Every ad format is described by an `ATFOAdSlot`:

```objc
ATFOAdSlot *adSlot = [[ATFOAdSlot alloc] init];
adSlot.slotID = @"YOUR_SLOT_ID";                 // slot ID
adSlot.adSize = CGSizeMake(width, height);       // ad size
adSlot.AdType = ATFOpenSDKAdTypeSplash;          // ad type
```

### 6.1 Splash

```objc
ATFOAdSlot *adSlot = [[ATFOAdSlot alloc] init];
adSlot.slotID = @"YOUR_SPLASH_SLOT_ID";
adSlot.adSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width,
                           UIScreen.mainScreen.bounds.size.height - 120);
adSlot.AdType = ATFOpenSDKAdTypeSplash;

self.splashAd = [[ATFOSplashAd alloc] initWithSlot:adSlot];
self.splashAd.delegate = self;

// Optional: custom bottom view
UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, adSlot.adSize.width, 120)];
self.splashAd.customBottomView = bottomView;

self.splashAd.rootViewController = self;
[self.splashAd loadAdData];

// Show after loading succeeds
[self.splashAd showSplashInRootViewController:self];

// Check validity before showing
BOOL isValid = [self.splashAd isValid];
```

Callbacks (`ATFOAdSplashDelegate`):

```objc
- (void)atfo_splashLoadedBy:(ATFOSplashAd *)splashAd with:(ATFOAdInfo *)adInfo;
- (void)atfo_splashLoadFailedBy:(ATFOSplashAd *)splashAd with:(NSError *)error;
- (void)atfo_splashShowSuccessBy:(ATFOSplashAd *)splashAd;
- (void)atfo_splashShowFailedBy:(ATFOSplashAd *)splashAd with:(NSError *)error;
- (void)atfo_splashClickBy:(ATFOSplashAd *)splashAd;
- (void)atfo_splashCloseBy:(ATFOSplashAd *)splashAd;
```

### 6.2 Interstitial

```objc
ATFOAdSlot *adSlot = [[ATFOAdSlot alloc] init];
adSlot.slotID = @"YOUR_INTERSTITIAL_SLOT_ID";
adSlot.AdType = ATFOpenSDKAdTypeInterstitial;
adSlot.adSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width,
                           UIScreen.mainScreen.bounds.size.height);

self.interstitialAd = [[ATFOInterstitialAd alloc] initWithSlot:adSlot];
self.interstitialAd.delegate = self;
[self.interstitialAd loadAdData];

// Show
[self.interstitialAd showInterstitialInRootViewController:self];
```

Callbacks (`ATFOAdInterstitialDelegate`):

```objc
- (void)atfo_interstitialLoadedBy:(ATFOInterstitialAd *)interstitialAd with:(ATFOAdInfo *)adInfo;
- (void)atfo_interstitialLoadFailedBy:(ATFOInterstitialAd *)interstitialAd with:(NSError *)error;
- (void)atfo_interstitialShowSuccessBy:(ATFOInterstitialAd *)interstitialAd;
- (void)atfo_interstitialShowFailedBy:(ATFOInterstitialAd *)interstitialAd with:(NSError *)error;
- (void)atfo_interstitialClickBy:(ATFOInterstitialAd *)interstitialAd;
- (void)atfo_interstitialCloseBy:(ATFOInterstitialAd *)interstitialAd;
```

### 6.3 Rewarded Video

```objc
ATFOAdSlot *adSlot = [[ATFOAdSlot alloc] init];
adSlot.slotID = @"YOUR_REWARD_SLOT_ID";
adSlot.AdType = ATFOpenSDKAdTypeRewardVideo;
adSlot.adSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width,
                           UIScreen.mainScreen.bounds.size.height);

self.rewardAd = [[ATFORewardVideoAd alloc] initWithSlot:adSlot];
self.rewardAd.delegate = self;
[self.rewardAd loadAdData];

// Show
[self.rewardAd showRewardVideoAdFromRootViewController:self];
```

Callbacks (`ATFOAdRewardVideoDelegate`):

```objc
- (void)atfo_rewardVideoLoadedBy:(ATFORewardVideoAd *)rewardVideoAd with:(ATFOAdInfo *)adInfo;
- (void)atfo_rewardVideoLoadFailedBy:(ATFORewardVideoAd *)rewardVideoAd with:(NSError *)error;
- (void)atfo_rewardVideoShowSuccessBy:(ATFORewardVideoAd *)rewardVideoAd;
- (void)atfo_rewardVideoShowFailedBy:(ATFORewardVideoAd *)rewardVideoAd with:(NSError *)error;
- (void)atfo_rewardVideoClickBy:(ATFORewardVideoAd *)rewardVideoAd;
- (void)atfo_rewardVideoCloseBy:(ATFORewardVideoAd *)rewardVideoAd;
- (void)atfo_rewardVideoPlayFinishedBy:(ATFORewardVideoAd *)rewardVideoAd;
- (void)atfo_rewardVideoDidRewardEffectiveBy:(ATFORewardVideoAd *)rewardVideoAd
                                 isEffective:(BOOL)isEffective
                                      verify:(BOOL)verify;
```

> Grant rewards only in `atfo_rewardVideoDidRewardEffectiveBy:isEffective:verify:`.

### 6.4 Feed (SDK Template Rendering)

```objc
ATFOAdSlot *adSlot = [[ATFOAdSlot alloc] init];
adSlot.slotID = @"YOUR_FEED_SLOT_ID";
adSlot.AdType = ATFOpenSDKAdTypeFeed;
adSlot.adSize = CGSizeMake(width, height);

self.feedAd = [[ATFOFeedAd alloc] initWithSlot:adSlot];
self.feedAd.delegate = self;
self.feedAd.rootViewController = self;   // used for ad landing pages
[self.feedAd loadAdData];

// Render after loading succeeds
[self.feedAd render];
```

Callbacks (`ATFOAdFeedDelegate`):

```objc
- (void)atfo_feedLoadedBy:(ATFOFeedAd *)feedAd with:(ATFOAdInfo *)adInfo;
- (void)atfo_feedLoadFailedBy:(ATFOFeedAd *)feedAd with:(NSError *)error;
- (void)atfo_feedRenderedBy:(ATFOFeedAd *)feedAd;
- (void)atfo_feedRenderFailBy:(ATFOFeedAd *)feedAd with:(NSError *)error;
- (void)atfo_feedClickBy:(ATFOFeedAd *)feedAd;
- (void)atfo_feedDidBecomeVisibleBy:(ATFOFeedAd *)feedAd;
- (void)atfo_feedDislikeCloseBy:(ATFOFeedAd *)feedAd;
```

### 6.5 Feed Self-Rendering

For self-rendering feeds the publisher builds the view. The SDK hands over the creative object and container view through `atfo_feedBeginRenderBy:with:at:`:

```objc
- (void)atfo_feedBeginRenderBy:(ATFOFeedAd *)feedAd
                          with:(id<ATFOUnifiedNativeAdObject>)adObject
                            at:(UIView *)adView {
    // Build your own view from the creative object
    FeedSelfRenderView *renderView = [FeedSelfRenderView viewWith:adObject];
    renderView.translatesAutoresizingMaskIntoConstraints = NO;
    [adView addSubview:renderView];

    [NSLayoutConstraint activateConstraints:@[
        [renderView.topAnchor constraintEqualToAnchor:adView.topAnchor],
        [renderView.leadingAnchor constraintEqualToAnchor:adView.leadingAnchor],
        [renderView.trailingAnchor constraintEqualToAnchor:adView.trailingAnchor],
        [renderView.bottomAnchor constraintEqualToAnchor:adView.bottomAnchor],
    ]];

    // Register the impression container and clickable views
    [adObject registerContainer:adView clickableViews:@[renderView.actionButton]];

    // Bind the data
    [renderView configureWith:adObject];
}
```

### 6.6 Feed (ATF Express Template)

When the server returns an ATF express creative (`render_type=atfExpress`, `style_id=9011`), render it into a container view:

```objc
// The slot configuration is the same as a regular feed slot,
// the only difference is the server-side template configuration
ATFOAdSlot *adSlot = [[ATFOAdSlot alloc] init];
adSlot.slotID = @"YOUR_FEED_ATFEXPRESS_SLOT_ID";
adSlot.AdType = ATFOpenSDKAdTypeFeed;
adSlot.adSize = CGSizeMake(width, height);

self.feedAd = [[ATFOFeedAd alloc] initWithSlot:adSlot];
self.feedAd.delegate = self;
self.feedAd.rootViewController = self;
[self.feedAd loadAdData];

// Render into the container view
[self.feedAd renderWithContainerView:self.adContainerView];
```

> The slot must be configured server-side with `render_type=atfExpress` and `style_id=9011`, otherwise no template creative is returned.

## 7. Permissions and Info.plist

The demo's `Info.plist` already contains the following entries. Mirror the ones you need in your own app.

### 7.1 Location Permission

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location is used to provide more relevant ad recommendations.</string>
```

### 7.2 App Tracking Transparency

```xml
<key>NSUserTrackingUsageDescription</key>
<string>Please allow tracking to receive more relevant ads.</string>
```

### 7.3 Launch Whitelist

Ad clicks may open third-party apps, so the corresponding schemes must be declared in `LSApplicationQueriesSchemes`:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>tmall</string>
    <string>baiduboxlite</string>
    <string>meituanwaimai</string>
    <!-- add more as needed -->
</array>
```

### 7.4 App Transport Security

Creatives and landing pages may use HTTP. The demo enables `NSAllowsArbitraryLoads`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 8. Logging and Debugging

```objc
// Enable online logging
[ATFOADLogSetting setATFOADOnLineLoggingEnabled:YES];

// Development prints more integration logs
config.environmentType = ATFOEnvironmentDevelopment;
```

The demo exposes log-related switches in `DemoConfig.h`:

| Switch | Description |
| --- | --- |
| `DEMO_ENABLE_VERBOSE_LOG` | Mirror ad callbacks to the console |
| `DEMO_TEST_MODE` | Print configuration details in the log panel |

## 9. Error Handling

Load and show failures are reported through the delegate `NSError` callbacks:

```objc
- (void)atfo_splashLoadFailedBy:(ATFOSplashAd *)splashAd with:(NSError *)error {
    NSLog(@"Splash load failed: code=%ld, %@", (long)error.code, error.localizedDescription);
}
```

Troubleshooting checklist:

1. Make sure the SDK finished initializing (`ATFOAdSDKManager.isInitialized`).
2. Make sure the credentials in `DemoConfig.h` are real and the slot ID matches the ad type.
3. Make sure the device has network access and the slot is enabled on the server.
4. Turn on verbose logging to inspect the request and callback chain.

## 10. FAQ

**Q: `pod install` cannot find ATFOpenAdSDK.**
A: Make sure `source 'https://github.com/atfoenginex/atfo-specs.git'` is present in the Podfile and run `pod repo update`.

**Q: Symbol conflicts or missing headers after integration.**
A: Make sure `use_frameworks! :linkage => :static` is enabled and that the `OTHER_SWIFT_FLAGS` and deployment target settings from `post_install` are applied.

**Q: Ad requests keep returning no fill.**
A: Make sure AppID, MediaID, SecretKey and the slot ID are real values and that the slot matches the `AdType`.

**Q: The splash bottom area looks wrong.**
A: The `adSize` height must leave room for the custom bottom view. The demo subtracts 120 from the screen height.

---

## License

[LICENSE](LICENSE)
