#import "InterstitialViewController.h"
#import "DemoConfig.h"
@import ATFOpenAdSDK;

@interface InterstitialViewController ()<ATFOAdInterstitialDelegate>

@property (nonatomic, strong) ATFOInterstitialAd *interstitialAd;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *loadButton;
@property (nonatomic, strong) UIButton *showButton;
@property (nonatomic, strong) UITextView *logTextView;

@end

@implementation InterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"插屏广告 Demo";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    [self setupUI];
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
    self.statusLabel.text = @"📱 插屏广告状态：未加载";
    self.statusLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.backgroundColor = DEMO_COLOR_DEFAULT;
    self.statusLabel.layer.cornerRadius = 8;
    self.statusLabel.layer.masksToBounds = YES;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.stackView addArrangedSubview:self.statusLabel];
    // 加载广告按钮
    self.loadButton = [self createButtonWithTitle:@"🚀 加载插屏广告"
                                          action:@selector(loadInterstitialAd:)
                                 backgroundColor:DEMO_COLOR_LOAD_BUTTON];
    [self.stackView addArrangedSubview:self.loadButton];
    
    // 展示广告按钮
    self.showButton = [self createButtonWithTitle:@"📺 展示插屏广告"
                                           action:@selector(showInterstitialAd:)
                                  backgroundColor:DEMO_COLOR_SHOW_BUTTON];
    [self.stackView addArrangedSubview:self.showButton];
    
    UIButton *checkButton = [self createButtonWithTitle:@"🔍 检查广告有效性"
                                                 action:@selector(checkIsValid:)
                                        backgroundColor:[UIColor systemPurpleColor]];
    [self.stackView addArrangedSubview:checkButton];
    
    // 创建功能说明
    UILabel *infoLabel = [[UILabel alloc] init];
    infoLabel.text = [NSString stringWithFormat:@"📋 功能说明：\n• 支持视频和图片插屏广告\n• %@摇一摇互动\n• 智能跳转（WebView/DeepLink/AppStore）\n• 点击关闭按钮或点击广告区域外关闭",
                     DEMO_ENABLE_SHAKE ? @"支持" : @"不支持"];
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
    self.logTextView.text = @"🎯 欢迎使用插屏广告 Demo！\n点击「加载插屏广告」开始体验...\n";
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

- (void)createInterstitialAd {
    // 创建广告位配置（使用 DemoConfig 中的常量）
    ATFOAdSlot *adSlot = [[ATFOAdSlot alloc] init];
    adSlot.slotID = DEMO_INTERSTITIAL_SLOT_ID;
    
    adSlot.AdType = ATFOpenSDKAdTypeInterstitial;
    adSlot.adSize = CGSizeMake(DEMO_INTERSTITIAL_WIDTH, DEMO_INTERSTITIAL_HEIGHT);
    
    // 创建插屏广告实例
    self.interstitialAd = [[ATFOInterstitialAd alloc] initWithSlot:adSlot];
    self.interstitialAd.delegate = self;
    
    [self addLog:@"✅ 插屏广告实例创建成功"];
    
    if (DEMO_TEST_MODE) {
        [self addLog:@"🧪 测试模式已启用"];
        [self addLog:[NSString stringWithFormat:@"📋 配置信息: AppID=%@, MediaID=%@, SlotID=%@",
                     DEMO_APP_ID, DEMO_MEDIA_ID, DEMO_INTERSTITIAL_SLOT_ID]];
    }
}

#pragma mark - Button Actions

- (void)loadInterstitialAd:(UIButton *)sender {
    [self addLog:@"🚀 开始加载插屏广告..."];
    self.statusLabel.text = @"📱 插屏广告状态：加载中...";
    self.statusLabel.backgroundColor = DEMO_COLOR_LOADING;
    self.statusLabel.textColor = [UIColor whiteColor];
    
    [self createInterstitialAd];
  
  [self.interstitialAd loadAdData];
  
}

- (void)showInterstitialAd:(UIButton *)sender {
    [self addLog:@"📺 开始展示插屏广告..."];
    // demo 中展示广告隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.interstitialAd showInterstitialInRootViewController:self];
}

- (void)checkIsValid:(UIButton *)sender {
    if (!self.interstitialAd) {
        [self addLog:@"❌ 广告实例不存在，请先加载广告"];
        return;
    }
    BOOL isValid = [self.interstitialAd isValid];
    [self addLog:[NSString stringWithFormat:@"🔍 广告有效性检查：%@", isValid ? @"✅ 有效" : @"❌ 无效"]];
}

#pragma mark - ATFOAdInterstitialDelegate

- (void)atfo_interstitialLoadedBy:(ATFOInterstitialAd *)interstitialAd with:(ATFOAdInfo *)adInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addLog: [NSString stringWithFormat:@"✅ 插屏广告加载成功！"]];
        self.statusLabel.text = @"📱 插屏广告状态：已加载，可展示";
        self.statusLabel.backgroundColor = DEMO_COLOR_SUCCESS;
        self.statusLabel.textColor = [UIColor whiteColor];
    });
}

- (void)atfo_interstitialLoadFailedBy:(ATFOInterstitialAd *)interstitialAd with:(NSError *)error {
  self.interstitialAd = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addLog:[NSString stringWithFormat:@"❌ 插屏广告加载失败：%@", error.localizedDescription]];
        self.statusLabel.text = @"📱 插屏广告状态：加载失败";
        self.statusLabel.backgroundColor = DEMO_COLOR_ERROR;
        self.statusLabel.textColor = [UIColor whiteColor];
    });
}

- (void)atfo_interstitialShowSuccessBy:(ATFOInterstitialAd *)interstitialAd {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addLog:@"🎉 插屏广告展示成功！"];
        self.statusLabel.text = @"📱 插屏广告状态：正在展示";
        self.statusLabel.backgroundColor = DEMO_COLOR_SHOWING;
        self.statusLabel.textColor = [UIColor whiteColor];
    });
}

- (void)atfo_interstitialShowFailedBy:(ATFOInterstitialAd *)interstitialAd with:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addLog:[NSString stringWithFormat:@"❌ 插屏广告展示失败：%@", error.localizedDescription]];
        self.statusLabel.text = @"📱 插屏广告状态：展示失败";
        self.statusLabel.backgroundColor = DEMO_COLOR_ERROR;
        self.statusLabel.textColor = [UIColor whiteColor];
        // 恢复导航栏
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    });
}

- (void)atfo_interstitialClickBy:(ATFOInterstitialAd *)interstitialAd{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addLog:@"👆 用户点击了插屏广告"];
    });
}

- (void)atfo_interstitialCloseBy:(ATFOInterstitialAd *)interstitialAd {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addLog:@"👋 插屏广告关闭"];
        self.statusLabel.text = @"📱 插屏广告状态：已关闭";
        self.statusLabel.backgroundColor = DEMO_COLOR_DEFAULT;
        self.statusLabel.textColor = [UIColor labelColor];
        self.interstitialAd = nil;
        // 恢复导航栏
        [self.navigationController setNavigationBarHidden:NO animated:YES];
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
