# ATFOpenAdSDKDemo
#
# 依赖来自公开 CocoaPods spec 仓库：
#   - https://github.com/atfoenginex/atfo-specs
#   - https://cdn.cocoapods.org

source 'https://cdn.cocoapods.org/'
source 'https://github.com/atfoenginex/atfo-specs.git'

platform :ios, '15.0'

inhibit_all_warnings!
workspace 'ATFOpenAdSDKDemo.xcworkspace'
project 'ATFOpenAdSDKDemo'
use_frameworks! :linkage => :static

target 'ATFOpenAdSDKDemo' do
  # 基础 UI 依赖
  pod 'Masonry'
  pod 'SDWebImage'

  # ATF 广告 SDK 核心
  pod 'ATFOpenAdSDK', '1.3.1.0'

  # 三方广告适配器（按需增删，版本以 atfo-specs 已发布版本为准）
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
