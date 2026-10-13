#import "ViewController.h"
#import "SplashViewController.h"
#import "InterstitialViewController.h"
#import "FeedViewController.h"
#import "RewardViewController.h"
#import "DemoConfig.h"
@import ATFOpenAdSDK;
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/ATTrackingManager.h>
#import "AppDelegate.h"

@interface ViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UITextField *uaTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ATF 广告 SDK Demo";
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
    
    // SDK 版本信息
    UILabel *versionLabel = [[UILabel alloc] init];
    NSString *idfa = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
    NSString *saplingID = @"—";
    Class saplingClass = NSClassFromString(@"ATFOSaplingSignature");
    if (saplingClass && [saplingClass respondsToSelector:@selector(saplingId)]) {
        saplingID = [saplingClass performSelector:@selector(saplingId)];
    }
    versionLabel.text = [NSString stringWithFormat:@"SDK 版本：%@\n测试模式：%@\n idfa: %@\n saplingID: %@",
                        @"1.2.7.5", DEMO_TEST_MODE ? @"开启" : @"关闭", idfa, saplingID];
    versionLabel.font = [UIFont systemFontOfSize:14];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.numberOfLines = 0;
    versionLabel.textColor = [UIColor systemGrayColor];
    versionLabel.backgroundColor = DEMO_COLOR_DEFAULT;
    versionLabel.layer.cornerRadius = 8;
    versionLabel.layer.masksToBounds = YES;
    versionLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(copyInfoTapped:)];
    [versionLabel addGestureRecognizer:tap];
    versionLabel.accessibilityIdentifier = @"versionInfoLabel";
    [self.stackView addArrangedSubview:versionLabel];
    
    // 自定义 UA 输入框
    self.uaTextField = [[UITextField alloc] init];
    self.uaTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.uaTextField.placeholder = @"输入自定义 User-Agent，留空恢复默认";
    self.uaTextField.text = ATFOAdSDKConfiguration.sharedConfiguration.customUserAgent;
    self.uaTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.uaTextField.heightAnchor constraintEqualToConstant:40].active = YES;
    [self.stackView addArrangedSubview:self.uaTextField];

    UIButton *uaButton = [self createButtonWithTitle:@"🌐 设置自定义 UA"
                                              action:@selector(setCustomUA:)
                                     backgroundColor:[UIColor systemOrangeColor]];
    [self.stackView addArrangedSubview:uaButton];

    // 开屏广告按钮
    UIButton *splashButton = [self createButtonWithTitle:@"🚀 开屏广告 Demo"
                                                  action:@selector(showSplashDemo:)
                                         backgroundColor:[UIColor blackColor]];
    [self.stackView addArrangedSubview:splashButton];
    
    // 插屏广告按钮
    UIButton *interstitialButton = [self createButtonWithTitle:@"📺 插屏广告 Demo"
                                                        action:@selector(showInterstitialDemo:)
                                               backgroundColor:[UIColor blackColor]];
    [self.stackView addArrangedSubview:interstitialButton];
    
    // 信息流广告按钮
    UIButton *feedButton = [self createButtonWithTitle:@"📰 信息流广告 Demo"
                                                action:@selector(showFeedDemo:)
                                       backgroundColor:[UIColor blackColor]];
    [self.stackView addArrangedSubview:feedButton];
  UIButton *selfRenderButton = [self createButtonWithTitle:@"📰 信息流自渲染广告 Demo"
                                                    action:@selector(showFeedSelfRenderDemo:)
                                           backgroundColor:[UIColor blackColor]];
  [self.stackView addArrangedSubview:selfRenderButton];
    UIButton *atfExpressButton = [self createButtonWithTitle:@"🔔 ATF 模板信息流 Demo"
                                                       action:@selector(showFeedATFExpressDemo:)
                                              backgroundColor:[UIColor systemIndigoColor]];
    [self.stackView addArrangedSubview:atfExpressButton];
    UIButton *rewardButton = [self createButtonWithTitle:@"🎬 激励视频广告 Demo"
                                                  action:@selector(showRewardDemo:)
                                         backgroundColor:[UIColor blackColor]];
    [self.stackView addArrangedSubview:rewardButton];
    
    // 创建 Switch
    UISwitch *mySwitch = [[UISwitch alloc] init];
    mySwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [self.stackView addArrangedSubview:mySwitch];
    // 添加事件监听
    [mySwitch addTarget:self
                     action:@selector(switchValueChanged:)
           forControlEvents:UIControlEventValueChanged];
    
    
    // 功能说明
    UILabel *infoLabel = [[UILabel alloc] init];
    infoLabel.text = @"📋 功能说明：\n• 支持开屏、插屏、信息流、激励视频广告\n• 支持视频和图片广告素材\n• 智能跳转（WebView/DeepLink/AppStore）\n• 支持摇一摇互动功能\n• 多广告源并发加载";
    infoLabel.font = [UIFont systemFontOfSize:14];
    infoLabel.numberOfLines = 0;
    infoLabel.textColor = [UIColor systemGrayColor];
    infoLabel.backgroundColor = DEMO_COLOR_DEFAULT;
    infoLabel.layer.cornerRadius = 8;
    infoLabel.layer.masksToBounds = YES;
    [self.stackView addArrangedSubview:infoLabel];
    
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

#pragma mark - Button Actions

- (void)showSplashDemo:(UIButton *)sender {
    SplashViewController *splashVC = [[SplashViewController alloc] init];
    [self.navigationController pushViewController:splashVC animated:YES];
}

- (void)showInterstitialDemo:(UIButton *)sender {
    InterstitialViewController *interstitialVC = [[InterstitialViewController alloc] init];
    [self.navigationController pushViewController:interstitialVC animated:YES];
}

- (void)showFeedDemo:(UIButton *)sender {
    FeedViewController *feedVC = [[FeedViewController alloc] init];
    [self.navigationController pushViewController:feedVC animated:YES];
}

- (void)showRewardDemo:(UIButton *)sender {
    RewardViewController *rewardVC = [[RewardViewController alloc] init];
    [self.navigationController pushViewController:rewardVC animated:YES];
}

- (void)showFeedSelfRenderDemo:(UIButton *) sender {
  FeedViewSelfRenderController *vc = [FeedViewSelfRenderController new];
  [self.navigationController pushViewController:vc animated:YES];
}

- (void)showFeedATFExpressDemo:(UIButton *)sender {
  FeedViewATFExpressController *vc = [FeedViewATFExpressController new];
  [self.navigationController pushViewController:vc animated:YES];
}

- (void)setCustomUA:(UIButton *)sender {
    NSString *ua = self.uaTextField.text;
    if (ua.length == 0) {
        ATFOAdSDKConfiguration.sharedConfiguration.customUserAgent = nil;
        NSLog(@"✅ 自定义 UA 已清除，使用默认 UA");
    } else {
        ATFOAdSDKConfiguration.sharedConfiguration.customUserAgent = ua;
        NSLog(@"✅ 自定义 UA 已设置：%@", ua);
    }
}

// Switch 值改变时的回调方法
- (void)switchValueChanged:(UISwitch *)sender {
    if (sender.isOn) {
        ATFOAdSDKConfiguration.sharedConfiguration.environmentType = ATFOEnvironmentTypeProduction;
        NSLog(@"启用正式环境");
    } else {
        ATFOAdSDKConfiguration.sharedConfiguration.environmentType = ATFOEnvironmentTypeDevelopment;
        NSLog(@"启用开发环境");
    }
}

#pragma mark - Copy Actions

- (void)copyInfoTapped:(UITapGestureRecognizer *)gesture {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"复制信息"
                                                                    message:nil
                                                             preferredStyle:UIAlertControllerStyleActionSheet];

    NSString *idfa = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];

    Class saplingClass = NSClassFromString(@"ATFOSaplingSignature");
    NSString *saplingID = @"—";
    if (saplingClass && [saplingClass respondsToSelector:@selector(saplingId)]) {
        saplingID = [saplingClass performSelector:@selector(saplingId)];
    }

    UIAlertAction *copyIDFAAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"复制 IDFA: %@", idfa]
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
        [UIPasteboard generalPasteboard].string = idfa;
    }];

    UIAlertAction *copySAPIDAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"复制 saplingID: %@", saplingID]
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
        [UIPasteboard generalPasteboard].string = saplingID;
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];

    [alert addAction:copyIDFAAction];
    [alert addAction:copySAPIDAction];
    [alert addAction:cancelAction];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.sourceView = gesture.view;
    }

    [self presentViewController:alert animated:YES completion:nil];
}

@end
