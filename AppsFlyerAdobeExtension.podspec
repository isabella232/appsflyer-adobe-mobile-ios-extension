Pod::Spec.new do |s|
  s.name             = 'AppsFlyerAdobeExtension'
  s.version          = '1.0.6'
  s.summary          = 'AppsFlyer iOS SDK Extension for Adobe Mobile SDK'

  s.description      = <<-DESC
AppsFlyer iOS SDK Extension for Adobe Mobile SDK.
                       DESC

  s.homepage         = 'https://github.com/AppsFlyerSDK/AppsFlyerAdobeExtension'
  s.license          = { :type => 'proprietary', :file => 'LICENSE' }
  s.author           = { 'AppsFlyer' => 'benjamin@appsflyer.com' }
  s.source           = { :git => 'https://github.com/AppsFlyerSDK/AppsFlyerAdobeExtension.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.source_files = 'AppsFlyerAdobeExtension/Classes/**/*'
  s.static_framework = true

  s.public_header_files = 'AppsFlyerAdobeExtension/Classes/**/*.h'
  s.dependency 'AppsFlyerFramework'
  s.dependency 'ACPCore'
end
