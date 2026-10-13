//
//  DemoConfig.h
//  ATFOpenAdSDKDemo
//
//  Demo 配置文件。
//
//  首次运行前，请把下面所有 YOUR_* 占位常量替换为你在 ATF 后台申请到的
//  真实 AppID / MediaID / SecretKey 与广告位 ID，否则 SDK 无法完成初始化，
//  广告位也无法请求到广告。
//

#ifndef DemoConfig_h
#define DemoConfig_h

#pragma mark - SDK 配置

// SDK App ID（必填）
#define DEMO_APP_ID @"YOUR_APP_ID"

// SDK Media ID（必填）
#define DEMO_MEDIA_ID @"YOUR_MEDIA_ID"

// SDK Secret Key（必填）
#define DEMO_SECRET_Key @"YOUR_SECRET_KEY"

#pragma mark - 开屏广告配置

// 开屏广告位 ID
#define DEMO_SPLASH_SLOT_ID @"YOUR_SPLASH_SLOT_ID"

// 开屏广告尺寸（默认全屏）
#define DEMO_SPLASH_WIDTH [UIScreen mainScreen].bounds.size.width
#define DEMO_SPLASH_HEIGHT [UIScreen mainScreen].bounds.size.height

#pragma mark - 插屏广告配置

// 插屏广告位 ID
#define DEMO_INTERSTITIAL_SLOT_ID @"YOUR_INTERSTITIAL_SLOT_ID"

// 插屏广告尺寸（默认全屏）
#define DEMO_INTERSTITIAL_WIDTH [UIScreen mainScreen].bounds.size.width
#define DEMO_INTERSTITIAL_HEIGHT [UIScreen mainScreen].bounds.size.height

#pragma mark - 激励视频广告配置

// 激励视频广告位 ID
#define DEMO_REWARD_SLOT_ID @"YOUR_REWARD_SLOT_ID"

// 激励视频广告尺寸（默认全屏）
#define DEMO_REWARD_WIDTH [UIScreen mainScreen].bounds.size.width
#define DEMO_REWARD_HEIGHT [UIScreen mainScreen].bounds.size.height

#pragma mark - 信息流广告配置

// 信息流广告位 ID
#define DEMO_FEED_SLOT_ID @"YOUR_FEED_SLOT_ID"

// 信息流自渲染广告位 ID
#define DEMO_FEED_SELFRENDER_SLOT_ID @"YOUR_FEED_SELFRENDER_SLOT_ID"

// ATF 模板渲染信息流广告位 ID（服务端需配置 render_type=atfExpress、style_id=9011）
#define DEMO_FEED_ATFEXPRESS_SLOT_ID @"YOUR_FEED_ATFEXPRESS_SLOT_ID"

// 信息流广告尺寸
#define DEMO_FEED_WIDTH ([UIScreen mainScreen].bounds.size.width - 40)
#define DEMO_FEED_HEIGHT (DEMO_FEED_WIDTH * 114 / 358.0)

#pragma mark - 测试配置

// 是否启用测试模式（使用 mock 数据）
#define DEMO_TEST_MODE YES

#pragma mark - UI 配置

// 状态标签高度
#define DEMO_STATUS_LABEL_HEIGHT 60.0f

// 按钮高度
#define DEMO_BUTTON_HEIGHT 50.0f

// 日志视图高度
#define DEMO_LOG_VIEW_HEIGHT 200.0f

// 界面边距
#define DEMO_UI_MARGIN 20.0f

// 控件间距
#define DEMO_UI_SPACING 20.0f

#pragma mark - 颜色配置

// 状态颜色
#define DEMO_COLOR_DEFAULT [UIColor systemGray6Color]
#define DEMO_COLOR_LOADING [UIColor systemBlueColor]
#define DEMO_COLOR_SUCCESS [UIColor systemGreenColor]
#define DEMO_COLOR_SHOWING [UIColor systemOrangeColor]
#define DEMO_COLOR_ERROR [UIColor systemRedColor]

// 按钮颜色
#define DEMO_COLOR_LOAD_BUTTON [UIColor systemBlueColor]
#define DEMO_COLOR_SHOW_BUTTON [UIColor systemGreenColor]

#pragma mark - 功能开关

// 是否启用摇一摇功能
#define DEMO_ENABLE_SHAKE YES

// 跳过按钮倒计时时间（秒）
#define DEMO_SKIP_COUNTDOWN_SECONDS 5

// 是否启用详细日志
#define DEMO_ENABLE_VERBOSE_LOG YES

#endif /* DemoConfig_h */
