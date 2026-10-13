# ATFOpenAdSDK iOS Demo

ATFOpenAdSDK 的 iOS 示例工程与接入文档。本仓库同时包含可直接运行的 Demo App 与完整的 SDK 接入指南。

iOS sample project and integration guide for ATFOpenAdSDK. This repository contains both a runnable demo app and the full integration guide.

---

## 目录

- [1. 简介](#1-简介)
- [2. 环境要求](#2-环境要求)
- [3. 快速开始：运行 Demo](#3-快速开始运行-demo)
- [4. 集成到你的 App](#4-集成到你的-app)
- [5. SDK 初始化](#5-sdk-初始化)
- [6. 广告接入](#6-广告接入)
- [7. 权限与 Info.plist](#7-权限与-infoplist)
- [8. 日志与调试](#8-日志与调试)
- [9. 错误处理](#9-错误处理)
- [10. 常见问题](#10-常见问题)
- [English Guide](#english-guide)

---

## 1. 简介

ATFOpenAdSDK 是 ATF 提供的 iOS 广告 SDK，支持开屏、插屏、激励视频、信息流等广告类型，并可通过适配器接入多家三方广告源参与竞价。

本仓库提供：

- 可直接运行的 Demo 工程 `ATFOpenAdSDKDemo.xcworkspace`
- 覆盖全部广告类型的示例代码 `ATFOpenAdSDKDemo/`
- 集中管理演示参数的配置文件 `ATFOpenAdSDKDemo/DemoConfig.h`

Demo 内置以下广告能力示例：

| 广告类型 | 入口 | 说明 |
| --- | --- | --- |
| 开屏广告 | `SplashViewController` | 全屏开屏，支持自定义底部视图与跳过 |
| 插屏广告 | `InterstitialViewController` | 全屏插屏 |
| 激励视频 | `RewardViewController` | 支持播放完成与奖励回调 |
| 信息流（模板） | `FeedViewController` | SDK 模板渲染 |
| 信息流（自渲染） | `FeedViewSelfRenderController` | 媒体自定义渲染视图 |
| ATF 模板信息流 | `FeedViewATFExpressController` | 服务端模板渲染 |

> Demo 还提供自定义 User-Agent、开发/正式环境切换、广告有效性检查与日志面板等辅助能力。

## 2. 环境要求

| 项 | 要求 |
| --- | --- |
| Xcode | 15 及以上 |
| iOS | 15.0 及以上 |
| CocoaPods | 1.13 及以上 |
| 语言 | Objective-C / Swift 混编（Demo 使用 ObjC + Swift） |

## 3. 快速开始：运行 Demo

```bash
# 1. 克隆仓库
git clone git@github.com:atfoenginex/ATFOpenAdSDKDemo.git
cd ATFOpenAdSDKDemo

# 2. 替换演示参数（见下）
#    编辑 ATFOpenAdSDKDemo/DemoConfig.h，把所有 YOUR_* 占位符替换为真实值

# 3. 安装依赖
pod install

# 4. 打开 workspace 运行
open ATFOpenAdSDKDemo.xcworkspace
```

**必须先完成第 2 步。** 仓库内的 `DemoConfig.h` 只包含占位常量，未替换前 SDK 无法初始化，广告请求也不会返回。

`ATFOpenAdSDKDemo/DemoConfig.h` 需要替换的常量：

| 常量 | 说明 |
| --- | --- |
| `DEMO_APP_ID` | SDK App ID |
| `DEMO_MEDIA_ID` | SDK Media ID |
| `DEMO_SECRET_Key` | SDK Secret Key |
| `DEMO_SPLASH_SLOT_ID` | 开屏广告位 ID |
| `DEMO_INTERSTITIAL_SLOT_ID` | 插屏广告位 ID |
| `DEMO_REWARD_SLOT_ID` | 激励视频广告位 ID |
| `DEMO_FEED_SLOT_ID` | 信息流广告位 ID |
| `DEMO_FEED_SELFRENDER_SLOT_ID` | 信息流自渲染广告位 ID |
| `DEMO_FEED_ATFEXPRESS_SLOT_ID` | ATF 模板信息流广告位 ID |

## 4. 集成到你的 App

### 4.1 配置 Podfile

依赖发布在公开 spec 仓库 [atfoenginex/atfo-specs](https://github.com/atfoenginex/atfo-specs)。

```ruby
source 'https://cdn.cocoapods.org/'
source 'https://github.com/atfoenginex/atfo-specs.git'

platform :ios, '15.0'
use_frameworks! :linkage => :static

target 'YourApp' do
  # ATF 广告 SDK 核心
  pod 'ATFOpenAdSDK', '1.3.1.0'

  # 三方广告适配器（按需引入）
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

执行：

```bash
pod install
```

### 4.2 引入头文件

Objective-C：

```objc
@import ATFOpenAdSDK;
// 或
#import <ATFOpenAdSDK/ATFOpenAdSDK.h>
```

Swift：

```swift
import ATFOpenAdSDK
```

## 5. SDK 初始化

在 `application:didFinishLaunchingWithOptions:` 中完成初始化。

```objc
ATFOAdSDKConfiguration *config = [ATFOAdSDKConfiguration sharedConfiguration];
config.appID = @"YOUR_APP_ID";
config.mediaID = @"YOUR_MEDIA_ID";
config.secretKey = @"YOUR_SECRET_KEY";

// 开发环境会输出更完整的联调日志，上线请改为 ATFOEnvironmentProduction
config.environmentType = ATFOEnvironmentDevelopment;
[ATFOADLogSetting setATFOADOnLineLoggingEnabled:YES];

// 如已自行获取设备标识，可按需传入（不传则由 SDK 自行采集）
// config.customIDFA = @"your_idfa";
// config.curID = @"custom_cur_id";
// config.curIDVersion = @"custom_cur_version";
// config.lastID = @"custom_last_id";
// config.lastIDVersion = @"custom_last_version";

// 业务用户标识，用于埋点与激励查奖
// config.userID = @"your_user_id";

// 自定义 User-Agent（可选）
// config.customUserAgent = @"your_user_agent";

[ATFOAdSDKManager startWithCompletionHandler:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        NSLog(@"ATF Open Ad SDK 初始化成功");
    } else {
        NSLog(@"ATF Open Ad SDK 初始化失败：%@", error.localizedDescription);
    }
}];
```

`ATFOAdSDKManager` 常用接口：

| 接口 | 说明 |
| --- | --- |
| `+ startWithCompletionHandler:` | 初始化 SDK，成功后才能请求广告 |
| `+ isInitialized` | 是否已初始化 |
| `+ getAvailableAdapterNames` | 当前已注册的适配器名称 |
| `+ clearLocalConfigs` | 清除本地缓存的配置 |

## 6. 广告接入

所有广告类型都通过 `ATFOAdSlot` 描述广告位：

```objc
ATFOAdSlot *adSlot = [[ATFOAdSlot alloc] init];
adSlot.slotID = @"YOUR_SLOT_ID";                 // 广告位 ID
adSlot.adSize = CGSizeMake(width, height);       // 广告尺寸
adSlot.AdType = ATFOpenSDKAdTypeSplash;          // 广告类型
```

### 6.1 开屏广告

```objc
ATFOAdSlot *adSlot = [[ATFOAdSlot alloc] init];
adSlot.slotID = @"YOUR_SPLASH_SLOT_ID";
adSlot.adSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width,
                           UIScreen.mainScreen.bounds.size.height - 120);
adSlot.AdType = ATFOpenSDKAdTypeSplash;

self.splashAd = [[ATFOSplashAd alloc] initWithSlot:adSlot];
self.splashAd.delegate = self;

// 可选：底部自定义视图
UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, adSlot.adSize.width, 120)];
self.splashAd.customBottomView = bottomView;

self.splashAd.rootViewController = self;
[self.splashAd loadAdData];

// 加载成功后展示
[self.splashAd showSplashInRootViewController:self];

// 展示前可检查有效性
BOOL isValid = [self.splashAd isValid];
```

回调（`ATFOAdSplashDelegate`）：

```objc
- (void)atfo_splashLoadedBy:(ATFOSplashAd *)splashAd with:(ATFOAdInfo *)adInfo;
- (void)atfo_splashLoadFailedBy:(ATFOSplashAd *)splashAd with:(NSError *)error;
- (void)atfo_splashShowSuccessBy:(ATFOSplashAd *)splashAd;
- (void)atfo_splashShowFailedBy:(ATFOSplashAd *)splashAd with:(NSError *)error;
- (void)atfo_splashClickBy:(ATFOSplashAd *)splashAd;
- (void)atfo_splashCloseBy:(ATFOSplashAd *)splashAd;
```

### 6.2 插屏广告

```objc
ATFOAdSlot *adSlot = [[ATFOAdSlot alloc] init];
adSlot.slotID = @"YOUR_INTERSTITIAL_SLOT_ID";
adSlot.AdType = ATFOpenSDKAdTypeInterstitial;
adSlot.adSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width,
                           UIScreen.mainScreen.bounds.size.height);

self.interstitialAd = [[ATFOInterstitialAd alloc] initWithSlot:adSlot];
self.interstitialAd.delegate = self;
[self.interstitialAd loadAdData];

// 展示
[self.interstitialAd showInterstitialInRootViewController:self];
```

回调（`ATFOAdInterstitialDelegate`）：

```objc
- (void)atfo_interstitialLoadedBy:(ATFOInterstitialAd *)interstitialAd with:(ATFOAdInfo *)adInfo;
- (void)atfo_interstitialLoadFailedBy:(ATFOInterstitialAd *)interstitialAd with:(NSError *)error;
- (void)atfo_interstitialShowSuccessBy:(ATFOInterstitialAd *)interstitialAd;
- (void)atfo_interstitialShowFailedBy:(ATFOInterstitialAd *)interstitialAd with:(NSError *)error;
- (void)atfo_interstitialClickBy:(ATFOInterstitialAd *)interstitialAd;
- (void)atfo_interstitialCloseBy:(ATFOInterstitialAd *)interstitialAd;
```

### 6.3 激励视频

```objc
ATFOAdSlot *adSlot = [[ATFOAdSlot alloc] init];
adSlot.slotID = @"YOUR_REWARD_SLOT_ID";
adSlot.AdType = ATFOpenSDKAdTypeRewardVideo;
adSlot.adSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width,
                           UIScreen.mainScreen.bounds.size.height);

self.rewardAd = [[ATFORewardVideoAd alloc] initWithSlot:adSlot];
self.rewardAd.delegate = self;
[self.rewardAd loadAdData];

// 展示
[self.rewardAd showRewardVideoAdFromRootViewController:self];
```

回调（`ATFOAdRewardVideoDelegate`）：

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

> 发放奖励请以 `atfo_rewardVideoDidRewardEffectiveBy:isEffective:verify:` 为准。

### 6.4 信息流广告（SDK 模板渲染）

```objc
ATFOAdSlot *adSlot = [[ATFOAdSlot alloc] init];
adSlot.slotID = @"YOUR_FEED_SLOT_ID";
adSlot.AdType = ATFOpenSDKAdTypeFeed;
adSlot.adSize = CGSizeMake(width, height);

self.feedAd = [[ATFOFeedAd alloc] initWithSlot:adSlot];
self.feedAd.delegate = self;
self.feedAd.rootViewController = self;   // 用于广告跳转
[self.feedAd loadAdData];

// 加载成功后渲染
[self.feedAd render];
```

回调（`ATFOAdFeedDelegate`）：

```objc
- (void)atfo_feedLoadedBy:(ATFOFeedAd *)feedAd with:(ATFOAdInfo *)adInfo;
- (void)atfo_feedLoadFailedBy:(ATFOFeedAd *)feedAd with:(NSError *)error;
- (void)atfo_feedRenderedBy:(ATFOFeedAd *)feedAd;
- (void)atfo_feedRenderFailBy:(ATFOFeedAd *)feedAd with:(NSError *)error;
- (void)atfo_feedClickBy:(ATFOFeedAd *)feedAd;
- (void)atfo_feedDidBecomeVisibleBy:(ATFOFeedAd *)feedAd;
- (void)atfo_feedDislikeCloseBy:(ATFOFeedAd *)feedAd;
```

### 6.5 信息流自渲染

自渲染信息流由媒体自行创建视图。SDK 通过 `atfo_feedBeginRenderBy:with:at:` 把素材对象与容器视图交给业务方：

```objc
- (void)atfo_feedBeginRenderBy:(ATFOFeedAd *)feedAd
                          with:(id<ATFOUnifiedNativeAdObject>)adObject
                            at:(UIView *)adView {
    // 用素材对象构建自定义视图
    FeedSelfRenderView *renderView = [FeedSelfRenderView viewWith:adObject];
    renderView.translatesAutoresizingMaskIntoConstraints = NO;
    [adView addSubview:renderView];

    [NSLayoutConstraint activateConstraints:@[
        [renderView.topAnchor constraintEqualToAnchor:adView.topAnchor],
        [renderView.leadingAnchor constraintEqualToAnchor:adView.leadingAnchor],
        [renderView.trailingAnchor constraintEqualToAnchor:adView.trailingAnchor],
        [renderView.bottomAnchor constraintEqualToAnchor:adView.bottomAnchor],
    ]];

    // 注册可点击区域与曝光容器
    [adObject registerContainer:adView clickableViews:@[renderView.actionButton]];

    // 填充数据
    [renderView configureWith:adObject];
}
```

### 6.6 ATF 模板信息流

服务端返回模板信息流素材（`render_type=atfExpress`、`style_id=9011`）时，使用容器视图渲染：

```objc
// 广告位配置与普通信息流一致，只是广告位在服务端被配置为模板渲染
ATFOAdSlot *adSlot = [[ATFOAdSlot alloc] init];
adSlot.slotID = @"YOUR_FEED_ATFEXPRESS_SLOT_ID";
adSlot.AdType = ATFOpenSDKAdTypeFeed;
adSlot.adSize = CGSizeMake(width, height);

self.feedAd = [[ATFOFeedAd alloc] initWithSlot:adSlot];
self.feedAd.delegate = self;
self.feedAd.rootViewController = self;
[self.feedAd loadAdData];

// 渲染到容器视图
[self.feedAd renderWithContainerView:self.adContainerView];
```

> 广告位需在服务端配置 `render_type=atfExpress`、`style_id=9011`，否则不会返回模板素材。

## 7. 权限与 Info.plist

Demo 的 `Info.plist` 已包含以下配置，接入时请按需同步到你的工程。

### 7.1 定位权限

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要访问您的位置，以便为您提供更精准的广告推荐服务。</string>
```

### 7.2 广告追踪（ATT）

```xml
<key>NSUserTrackingUsageDescription</key>
<string>请选择允许</string>
```

### 7.3 跳转白名单

广告点击可能需要唤起三方 App，需在 `LSApplicationQueriesSchemes` 中声明对应 scheme：

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>tmall</string>
    <string>baiduboxlite</string>
    <string>meituanwaimai</string>
    <!-- 其余按需补充 -->
</array>
```

### 7.4 ATS

广告素材与落地页可能使用 HTTP，Demo 开启了 `NSAllowsArbitraryLoads`：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 8. 日志与调试

```objc
// 开启在线日志
[ATFOADLogSetting setATFOADOnLineLoggingEnabled:YES];

// 开发环境会输出更完整的联调日志
config.environmentType = ATFOEnvironmentDevelopment;
```

Demo 在 `DemoConfig.h` 中提供了日志相关开关：

| 开关 | 说明 |
| --- | --- |
| `DEMO_ENABLE_VERBOSE_LOG` | 是否把广告回调同步输出到控制台 |
| `DEMO_TEST_MODE` | 是否在日志面板输出配置信息 |

## 9. 错误处理

广告加载与展示失败会通过 delegate 的 `NSError` 回调返回，示例：

```objc
- (void)atfo_splashLoadFailedBy:(ATFOSplashAd *)splashAd with:(NSError *)error {
    NSLog(@"开屏广告加载失败：code=%ld, %@", (long)error.code, error.localizedDescription);
}
```

排查建议：

1. 确认 SDK 已初始化成功（`ATFOAdSDKManager.isInitialized`）。
2. 确认 `DemoConfig.h` 中的参数已替换为真实值，且广告位 ID 与广告类型匹配。
3. 确认设备网络正常，且广告位已在后台开启。
4. 打开详细日志观察请求与回调链路。

## 10. 常见问题

**Q：`pod install` 找不到 ATFOpenAdSDK？**
A：确认 Podfile 中已加入 `source 'https://github.com/atfoenginex/atfo-specs.git'`，并执行 `pod repo update`。

**Q：集成后编译报符号冲突或找不到头文件？**
A：确认 `use_frameworks! :linkage => :static` 已开启，且 `post_install` 中的 `OTHER_SWIFT_FLAGS` 与部署目标配置已同步。

**Q：广告请求一直返回无填充？**
A：确认 AppID / MediaID / SecretKey / 广告位 ID 均为真实值，且广告位与 `AdType` 匹配。

**Q：开屏广告底部区域显示异常？**
A：`adSize` 的高度需预留底部自定义视图高度，Demo 中为屏幕高度减去 120。

---

# English Guide

## 1. Introduction

ATFOpenAdSDK is ATF's iOS advertising SDK. It supports splash, interstitial, rewarded video and feed ads, and can aggregate multiple third-party ad sources through adapters.

This repository provides:

- A runnable demo project: `ATFOpenAdSDKDemo.xcworkspace`
- Sample code for every ad format under `ATFOpenAdSDKDemo/`
- A single configuration file for demo parameters: `ATFOpenAdSDKDemo/DemoConfig.h`

| Ad format | Entry point |
| --- | --- |
| Splash | `SplashViewController` |
| Interstitial | `InterstitialViewController` |
| Rewarded video | `RewardViewController` |
| Feed (template) | `FeedViewController` |
| Feed (self-rendering) | `FeedViewSelfRenderController` |
| Feed (ATF express) | `FeedViewATFExpressController` |

## 2. Requirements

| Item | Requirement |
| --- | --- |
| Xcode | 15 or later |
| iOS | 15.0 or later |
| CocoaPods | 1.13 or later |
| Languages | Objective-C and Swift |

## 3. Quick Start

```bash
git clone git@github.com:atfoenginex/ATFOpenAdSDKDemo.git
cd ATFOpenAdSDKDemo

# Replace every YOUR_* placeholder in ATFOpenAdSDKDemo/DemoConfig.h first

pod install
open ATFOpenAdSDKDemo.xcworkspace
```

The demo ships with placeholder credentials only. Until you replace them, the SDK cannot initialize and ad requests will not be filled.

## 4. Installation

Dependencies are published in the public spec repository [atfoenginex/atfo-specs](https://github.com/atfoenginex/atfo-specs).

```ruby
source 'https://cdn.cocoapods.org/'
source 'https://github.com/atfoenginex/atfo-specs.git'

platform :ios, '15.0'
use_frameworks! :linkage => :static

target 'YourApp' do
  pod 'ATFOpenAdSDK', '1.3.1.0'

  # Add the adapters you need
  pod 'ATFOBaiduAdapter', '1.3.0.0'
  pod 'ATFOGDTAdapter', '1.3.1.0'
  pod 'ATFOGroMoreAdapter', '1.3.0.0'
end
```

## 5. SDK Initialization

```objc
ATFOAdSDKConfiguration *config = [ATFOAdSDKConfiguration sharedConfiguration];
config.appID = @"YOUR_APP_ID";
config.mediaID = @"YOUR_MEDIA_ID";
config.secretKey = @"YOUR_SECRET_KEY";
config.environmentType = ATFOEnvironmentDevelopment;
[ATFOADLogSetting setATFOADOnLineLoggingEnabled:YES];

[ATFOAdSDKManager startWithCompletionHandler:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        NSLog(@"SDK initialized");
    } else {
        NSLog(@"SDK init failed: %@", error.localizedDescription);
    }
}];
```

## 6. Loading Ads

Every ad format is described by an `ATFOAdSlot`.

### 6.1 Splash

```objc
ATFOAdSlot *adSlot = [[ATFOAdSlot alloc] init];
adSlot.slotID = @"YOUR_SPLASH_SLOT_ID";
adSlot.adSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width,
                           UIScreen.mainScreen.bounds.size.height - 120);
adSlot.AdType = ATFOpenSDKAdTypeSplash;

self.splashAd = [[ATFOSplashAd alloc] initWithSlot:adSlot];
self.splashAd.delegate = self;
self.splashAd.rootViewController = self;
[self.splashAd loadAdData];
[self.splashAd showSplashInRootViewController:self];
```

### 6.2 Interstitial

```objc
adSlot.AdType = ATFOpenSDKAdTypeInterstitial;
self.interstitialAd = [[ATFOInterstitialAd alloc] initWithSlot:adSlot];
self.interstitialAd.delegate = self;
[self.interstitialAd loadAdData];
[self.interstitialAd showInterstitialInRootViewController:self];
```

### 6.3 Rewarded Video

```objc
adSlot.AdType = ATFOpenSDKAdTypeRewardVideo;
self.rewardAd = [[ATFORewardVideoAd alloc] initWithSlot:adSlot];
self.rewardAd.delegate = self;
[self.rewardAd loadAdData];
[self.rewardAd showRewardVideoAdFromRootViewController:self];
```

Grant rewards only in `atfo_rewardVideoDidRewardEffectiveBy:isEffective:verify:`.

### 6.4 Feed

```objc
adSlot.AdType = ATFOpenSDKAdTypeFeed;
self.feedAd = [[ATFOFeedAd alloc] initWithSlot:adSlot];
self.feedAd.delegate = self;
self.feedAd.rootViewController = self;
[self.feedAd loadAdData];
[self.feedAd render];
```

For self-rendering feeds implement `atfo_feedBeginRenderBy:with:at:`, build your own view from the provided native ad object, and register the container and clickable views with `registerContainer:clickableViews:`. For server-side templates call `renderWithContainerView:`.

## 7. Info.plist

Add the location usage description, the ATT usage description, the `LSApplicationQueriesSchemes` whitelist for third-party app launches, and an ATS exception if creatives or landing pages use HTTP. See section 7 of the Chinese guide for the exact keys.

## 8. Logging and Troubleshooting

Enable online logging with `[ATFOADLogSetting setATFOADOnLineLoggingEnabled:YES]` and use `ATFOEnvironmentDevelopment` while integrating. If ads are not filled, verify the credentials, the slot ID, the slot-to-ad-type mapping, network connectivity, and that the slot is enabled on the server.

---

## License

[LICENSE](LICENSE)
