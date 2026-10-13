#import "FeedViewController.h"
#import "DemoConfig.h"
#import <ATFOpenAdSDK/ATFOpenAdSDK.h>
#import "ATFOpenAdSDKDemo-Swift.h"
@import Masonry;

@interface FeedViewController ()<ATFOAdFeedDelegate>

@property (nonatomic, strong) ATFOFeedAd *feedAd;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *loadButton;
@property (nonatomic, strong) UIButton *renderButton;
@property (nonatomic, strong) UIView *adContainerView;
@property (nonatomic, strong) UITextView *logTextView;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"信息流广告 Demo";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    [self setupUI];
}

- (NSString *)defaultSlotID {
    if ([self isKindOfClass:FeedViewSelfRenderController.class]) {
        return DEMO_FEED_SELFRENDER_SLOT_ID;
    }
    return DEMO_FEED_SLOT_ID;
}

- (void)setupUI {
    // 创建滚动视图
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];
    
    // 创建主容器 StackView
    self.stackView = [[UIStackView alloc] init];
    self.stackView.axis = UILayoutConstraintAxisVertical;
    self.stackView.spacing = DEMO_UI_SPACING;
    self.stackView.alignment = UIStackViewAlignmentFill;
    self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.stackView];
    
    // 状态标签
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = @"📱 信息流广告状态：未加载";
    self.statusLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.backgroundColor = DEMO_COLOR_DEFAULT;
    self.statusLabel.layer.cornerRadius = 8;
    self.statusLabel.layer.masksToBounds = YES;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.stackView addArrangedSubview:self.statusLabel];
    // 加载广告按钮
    self.loadButton = [self createButtonWithTitle:@"🚀 加载信息流广告"
                                          action:@selector(loadFeedAd:)
                                 backgroundColor:DEMO_COLOR_LOAD_BUTTON];
    [self.stackView addArrangedSubview:self.loadButton];
    
    // 渲染广告按钮
    self.renderButton = [self createButtonWithTitle:@"🎨 渲染信息流广告"
                                             action:@selector(renderFeedAd:)
                                    backgroundColor:DEMO_COLOR_SHOW_BUTTON];
    [self.stackView addArrangedSubview:self.renderButton];
    
    UIButton *checkButton = [self createButtonWithTitle:@"🔍 检查广告有效性"
                                                 action:@selector(checkIsValid:)
                                        backgroundColor:[UIColor systemPurpleColor]];
    [self.stackView addArrangedSubview:checkButton];
    
    // 广告展示容器
    self.adContainerView = [[UIView alloc] init];
    self.adContainerView.backgroundColor = [UIColor systemGray6Color];
    self.adContainerView.layer.cornerRadius = 8;
    self.adContainerView.layer.masksToBounds = YES;
    self.adContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.stackView addArrangedSubview:self.adContainerView];
    
    // 添加占位标签
    UILabel *placeholderLabel = [[UILabel alloc] init];
    placeholderLabel.text = @"📺 广告展示区域\n加载并渲染成功后，广告将在此处显示";
    placeholderLabel.textAlignment = NSTextAlignmentCenter;
    placeholderLabel.numberOfLines = 0;
    placeholderLabel.font = [UIFont systemFontOfSize:14];
    placeholderLabel.textColor = [UIColor systemGrayColor];
    placeholderLabel.tag = 999; // 用于后续移除
    placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.adContainerView addSubview:placeholderLabel];
    
    // 创建功能说明
    UILabel *infoLabel = [[UILabel alloc] init];
    infoLabel.text = @"📋 功能说明：\n• 支持视频和图片信息流广告\n• 16:9比例展示效果最佳\n• 智能跳转（WebView/DeepLink/AppStore）\n• 支持摇一摇互动功能\n• 需要先加载再渲染显示";
    infoLabel.font = [UIFont systemFontOfSize:14];
    infoLabel.numberOfLines = 0;
    infoLabel.textColor = [UIColor systemGrayColor];
    infoLabel.backgroundColor = DEMO_COLOR_DEFAULT;
    infoLabel.layer.cornerRadius = 8;
    infoLabel.layer.masksToBounds = YES;
    [self.stackView addArrangedSubview:infoLabel];
    
    // 日志显示区域
    UILabel *logTitle = [[UILabel alloc] init];
    logTitle.text = @"📝 事件日志：";
    logTitle.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [self.stackView addArrangedSubview:logTitle];
    
    self.logTextView = [[UITextView alloc] init];
    self.logTextView.font = [UIFont systemFontOfSize:12];
    self.logTextView.backgroundColor = DEMO_COLOR_DEFAULT;
    self.logTextView.layer.cornerRadius = 8;
    self.logTextView.layer.masksToBounds = YES;
    self.logTextView.editable = NO;
    self.logTextView.text = @"🎯 欢迎使用信息流广告 Demo！\n点击「加载信息流广告」开始体验...\n";
    self.logTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.stackView addArrangedSubview:self.logTextView];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        // ScrollView 约束
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        // StackView 约束
        [self.stackView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor constant:DEMO_UI_MARGIN],
        [self.stackView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor constant:DEMO_UI_MARGIN],
        [self.stackView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor constant:-DEMO_UI_MARGIN],
        [self.stackView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor constant:-DEMO_UI_MARGIN],
        [self.stackView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor constant:-2*DEMO_UI_MARGIN],
        
        // 状态标签高度
        [self.statusLabel.heightAnchor constraintEqualToConstant:DEMO_STATUS_LABEL_HEIGHT],
        
        // 广告容器高度
        [self.adContainerView.heightAnchor constraintEqualToConstant:798],
        
        // 占位标签约束
        [placeholderLabel.centerXAnchor constraintEqualToAnchor:self.adContainerView.centerXAnchor],
        [placeholderLabel.centerYAnchor constraintEqualToAnchor:self.adContainerView.centerYAnchor],
        [placeholderLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.adContainerView.leadingAnchor constant:DEMO_UI_MARGIN],
        [placeholderLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.adContainerView.trailingAnchor constant:-DEMO_UI_MARGIN],
        
        // 日志区域高度
        [self.logTextView.heightAnchor constraintEqualToConstant:DEMO_LOG_VIEW_HEIGHT],
    ]];
}

- (UIButton *)createButtonWithTitle:(NSString *)title
                             action:(SEL)action
                    backgroundColor:(UIColor *)backgroundColor {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    button.backgroundColor = backgroundColor;
    button.layer.cornerRadius = 8;
    button.layer.masksToBounds = YES;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button.heightAnchor constraintEqualToConstant:DEMO_BUTTON_HEIGHT].active = YES;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)createFeedAd {
    // 创建广告位配置（使用 DemoConfig 中的常量）
    ATFOAdSlot *adSlot = [[ATFOAdSlot alloc] init];
    adSlot.slotID = self.defaultSlotID;
    
    adSlot.AdType = ATFOpenSDKAdTypeFeed;
    adSlot.adSize = CGSizeMake(DEMO_FEED_WIDTH, DEMO_FEED_HEIGHT);
    
    // 创建信息流广告实例
    self.feedAd = [[ATFOFeedAd alloc] initWithSlot:adSlot];
    self.feedAd.delegate = self;
    self.feedAd.rootViewController = self; // 设置根视图控制器，用于跳转
    
    [self addLog:@"✅ 信息流广告实例创建成功"];
    
    if (DEMO_TEST_MODE) {
        [self addLog:@"🧪 测试模式已启用"];
        [self addLog:[NSString stringWithFormat:@"📋 配置信息: AppID=%@, MediaID=%@, SlotID=%@",
                     DEMO_APP_ID, DEMO_MEDIA_ID, adSlot.slotID]];
    }
}

#pragma mark - Button Actions

- (void)loadFeedAd:(UIButton *)sender {
    [self addLog:@"🚀 开始加载信息流广告..."];
    self.statusLabel.text = @"📱 信息流广告状态：加载中...";
    self.statusLabel.backgroundColor = DEMO_COLOR_LOADING;
    self.statusLabel.textColor = [UIColor whiteColor];
    
    [self createFeedAd];
    
    [self.feedAd loadAdData];
}

- (void)renderFeedAd:(UIButton *)sender {
    [self addLog:@"🎨 开始渲染信息流广告..."];
    
    if (!self.feedAd) {
        [self addLog:@"❌ 请先加载广告再进行渲染"];
        return;
    }
    
    [self.feedAd render];
}

- (void)checkIsValid:(UIButton *)sender {
    if (!self.feedAd) {
        [self addLog:@"❌ 广告实例不存在，请先加载广告"];
        return;
    }
    BOOL isValid = [self.feedAd isValid];
    [self addLog:[NSString stringWithFormat:@"🔍 广告有效性检查：%@", isValid ? @"✅ 有效" : @"❌ 无效"]];
}

#pragma mark - ATFOAdFeedDelegate

- (void)atfo_feedLoadedBy:(ATFOFeedAd *)feedAd with:(ATFOAdInfo *)adInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addLog:@"✅ 信息流广告加载成功！"];
        self.statusLabel.text = @"📱 信息流广告状态：已加载，可渲染";
        self.statusLabel.backgroundColor = DEMO_COLOR_SUCCESS;
        self.statusLabel.textColor = [UIColor whiteColor];
    });
}

- (void)atfo_feedLoadFailedBy:(ATFOFeedAd *)feedAd with:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addLog:[NSString stringWithFormat:@"❌ 信息流广告加载失败：%@", error.localizedDescription]];
        self.statusLabel.text = @"📱 信息流广告状态：加载失败";
        self.statusLabel.backgroundColor = DEMO_COLOR_ERROR;
        self.statusLabel.textColor = [UIColor whiteColor];
    });
}

- (void)atfo_feedRenderedBy:(ATFOFeedAd *)feedAd {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addLog:@"🎨 信息流广告渲染成功！"];
        self.statusLabel.text = @"📱 信息流广告状态：已渲染，正在展示";
        self.statusLabel.backgroundColor = DEMO_COLOR_SHOWING;
        self.statusLabel.textColor = [UIColor whiteColor];
        UIView *placeholder = [self.adContainerView viewWithTag:999];
        [placeholder removeFromSuperview];
        if (self.feedAd.adView) {
            self.feedAd.adView.translatesAutoresizingMaskIntoConstraints = NO;
            [self.adContainerView addSubview:self.feedAd.adView];
            [NSLayoutConstraint activateConstraints:@[
                [self.feedAd.adView.centerXAnchor constraintEqualToAnchor:self.adContainerView.centerXAnchor],
                [self.feedAd.adView.topAnchor constraintEqualToAnchor:self.adContainerView.topAnchor],
                [self.feedAd.adView.widthAnchor constraintEqualToConstant:DEMO_FEED_WIDTH],
                [self.feedAd.adView.heightAnchor constraintEqualToConstant:DEMO_FEED_HEIGHT],
            ]];
        }
    });
}

- (void)atfo_feedRenderFailBy:(ATFOFeedAd *)feedAd with:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addLog:[NSString stringWithFormat:@"❌ 信息流广告渲染失败：%@", error.localizedDescription]];
        self.statusLabel.text = @"📱 信息流广告状态：渲染失败";
        self.statusLabel.backgroundColor = DEMO_COLOR_ERROR;
        self.statusLabel.textColor = [UIColor whiteColor];
    });
}

- (void)atfo_feedClickBy:(ATFOFeedAd *)feedAd {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addLog:@"👆 用户点击了信息流广告"];
    });
}

- (void)atfo_feedDidBecomeVisibleBy:(ATFOFeedAd *)feedAd {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addLog:@"👁️ 信息流广告已曝光"];
    });
}

- (void)atfo_feedDislikeCloseBy:(ATFOFeedAd *)feedAd {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addLog:@"👋 用户关闭了信息流广告"];
        self.statusLabel.text = @"📱 信息流广告状态：已关闭";
        self.statusLabel.backgroundColor = DEMO_COLOR_DEFAULT;
        self.statusLabel.textColor = [UIColor labelColor];
        
        // 移除广告视图，恢复占位标签
        if (self.feedAd.adView) {
            [self.feedAd.adView removeFromSuperview];
        }
        
        // 重新添加占位标签
        UILabel *placeholderLabel = [[UILabel alloc] init];
        placeholderLabel.text = @"📺 广告展示区域\n广告已关闭，可重新加载";
        placeholderLabel.textAlignment = NSTextAlignmentCenter;
        placeholderLabel.numberOfLines = 0;
        placeholderLabel.font = [UIFont systemFontOfSize:14];
        placeholderLabel.textColor = [UIColor systemGrayColor];
        placeholderLabel.tag = 999;
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.adContainerView addSubview:placeholderLabel];
        
        [NSLayoutConstraint activateConstraints:@[
            [placeholderLabel.centerXAnchor constraintEqualToAnchor:self.adContainerView.centerXAnchor],
            [placeholderLabel.centerYAnchor constraintEqualToAnchor:self.adContainerView.centerYAnchor],
            [placeholderLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.adContainerView.leadingAnchor constant:DEMO_UI_MARGIN],
            [placeholderLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.adContainerView.trailingAnchor constant:-DEMO_UI_MARGIN],
        ]];
        
        self.feedAd = nil;
    });
}

#pragma mark - Helper Methods

- (void)addLog:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm:ss";
        NSString *timestamp = [formatter stringFromDate:[NSDate date]];
        
        NSString *logMessage = [NSString stringWithFormat:@"[%@] %@\n", timestamp, message];
        self.logTextView.text = [self.logTextView.text stringByAppendingString:logMessage];
        
        // 滚动到底部
        NSRange bottom = NSMakeRange(self.logTextView.text.length - 1, 1);
        [self.logTextView scrollRangeToVisible:bottom];
        
        // 根据配置决定是否输出详细日志
        if (DEMO_ENABLE_VERBOSE_LOG) {
            NSLog(@"%@", message);
        }
    });
}

@end 

@implementation FeedViewSelfRenderController

- (void)createFeedAd {
    // 创建广告位配置（使用 DemoConfig 中的常量）
    ATFOAdSlot *adSlot = [[ATFOAdSlot alloc] init];
    
    adSlot.slotID = DEMO_FEED_SELFRENDER_SLOT_ID;
    
    adSlot.AdType = ATFOpenSDKAdTypeFeed;
    adSlot.adSize = CGSizeMake(DEMO_FEED_WIDTH, DEMO_FEED_HEIGHT);
    
    // 创建信息流广告实例
    self.feedAd = [[ATFOFeedAd alloc] initWithSlot:adSlot];
    self.feedAd.delegate = self;
    self.feedAd.rootViewController = self; // 设置根视图控制器，用于跳转
    
    [self addLog:@"✅ 信息流广告实例创建成功"];
    
    if (DEMO_TEST_MODE) {
        [self addLog:@"🧪 测试模式已启用"];
        [self addLog:[NSString stringWithFormat:@"📋 配置信息: AppID=%@, MediaID=%@, SlotID=%@",
                     DEMO_APP_ID, DEMO_MEDIA_ID, adSlot.slotID]];
    }
}

- (void)atfo_feedBeginRenderBy:(ATFOFeedAd *)feedAd with:(id<ATFOUnifiedNativeAdObject>)adObject at:(UIView *)adView {
  FeedSelfRenderView *renderView = [FeedSelfRenderView viewWith:adObject];
  renderView.translatesAutoresizingMaskIntoConstraints = NO;
  [adView addSubview:renderView];
  
  [NSLayoutConstraint activateConstraints:@[
    [renderView.topAnchor constraintEqualToAnchor:adView.topAnchor],
    [renderView.leadingAnchor constraintEqualToAnchor:adView.leadingAnchor],
    [renderView.trailingAnchor constraintEqualToAnchor:adView.trailingAnchor],
    [renderView.bottomAnchor constraintEqualToAnchor:adView.bottomAnchor],
  ]];
  
  __weak typeof(adView) weakAdView = adView;
  __weak typeof(self) weak_self = self;
  [renderView setOnClose:^{
    [adObject unregisterData];
    [weakAdView removeFromSuperview];
    [weak_self atfo_feedDislikeCloseBy:weak_self.feedAd];
  }];
  [adObject registerContainer:adView clickableViews:@[renderView.actionButton]];

  [renderView configureWith:adObject];
}

- (void)dealloc {
  NSLog(@"=====");
}

@end
