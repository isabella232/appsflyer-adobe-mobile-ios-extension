

# AppsFlyer SDK Extension for Adobe Mobile SDK

[![Version](https://img.shields.io/cocoapods/v/AppsFlyerAdobeExtension.svg?style=flat)](https://cocoapods.org/pods/AppsFlyerAdobeExtension)

[![Platform](https://img.shields.io/cocoapods/p/AppsFlyerAdobeExtension.svg?style=flat)](https://cocoapods.org/pods/AppsFlyerAdobeExtension)

## Table of content
- [Installation](#installation)
- [Extension Initializaiton](#initialization)

- [Event Tracking](#eventTracking)

- [Extension Callbacks](#callbacks)

- [Tracking Deep Links](#deeplinks)

- [Example App](#example)

- [Attribution Data tracking with Adobe Analytics](#analyticsPostback)

## <a id="installation">  Installation

Import the latest `AppsFlyerAdobeExtension` from cocoaPods:
```objectivec
pod 'AppsFlyerAdobeExtension', '~> 1.0'
```
## <a id="initialization"> Extension Initialization
Register the AppsFlyer Extension from the `applicationDidFinishLaunchingWithOptions` method, alongside the Adobe SDK initialization code:
```objectivec
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions :(NSDictionary *)launchOptions {
...
// Override point for customization after application launch.
[ACPCore  configureWithAppId:@"yourAdobeLaunchID"];
[AppsFlyerAdobeExtension  registerExtension];
...
}
```


For additional instructions on using AppsFlyer's Adobe Mobile SDK Extension please see: https://aep-sdks.gitbook.io/docs/getting-started/create-a-mobile-property

After adding the extension to the mobile property, please set the App ID and Dev Key fields and save the extension settings.

![AppsFlyerAdobeSDK](https://github.com/AppsFlyerSDK/AppsFlyerAdobeExtension/blob/master/gitresources/img.png)

For more information on adding applications to the AppsFlyer dashboard see [here](https://support.appsflyer.com/hc/en-us/articles/207377436-Adding-a-New-App-to-the-AppsFlyer-Dashboard)



Information on adding the extension to xCode is available on the Launch dashboard.


## <a id="eventTracking"> Event Tracking
All events that are invoked using the `[ACPCore  trackAction]` API are automatically tracked to the AppsFlyer Platform as in-app events; For example, calling this API:
```
[ACPCore  trackAction:@"testAnalyticsAction" data:@{@"revenue":@"200",@"currency":@"USD"];
```
will result in a `testAnalyticsAction` event tracked on the AppsFlyer Dashboard with a revenue of 200USD.

 `revenue` and `currency` parameters are mapped to `af_revenue` and `af_currency`.


## <a id="callbacks"> Extension Callbacks
 Registering for deferred deep link and deep link callbacks:
```
   [AppsFlyerAdobeExtension registerCallbacks:^(NSDictionary *dictionary) {
        NSLog(@"[AppsFlyerAdobeExtension] Received callback: %@", dictionary);
    }];
```
Handling Errors:
```
    [AppsFlyerAdobeExtension callbacksErrorHandler:^(NSError *error) {
        NSLog(@"[AppsFlyerAdobeExtension] Error receivng callback: %@" , error);
    }];
``` 
The returned map should contain a `callback_type` key to distinguish between `onConversionDataReceived` (deferred deep link) and `onAppOpenAttribution`  (deep link).


## <a id="deeplinks"> Tracking Deep Links
Tracking  **Universal Links** using the AppsFlyerAdobeExtension requires the developer to pass the userActivity and restorationHandler to the extension:
```
- (BOOL) application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> *restorableObjects))restorationHandler {
    [AppsFlyerAdobeExtension continueUserActivity:userActivity restorationHandler:restorationHandler];
    return  YES;

}
```

Tracking URL Types (Schemes) using the AppsFlyerAdobeExtension requires the developer to pass the url and options to the extension:
```
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary *) options {
	[AppsFlyerAdobeExtension  openURL:url options:options];
	return  YES;
}
```

## <a id="example">  Example Application Usage:
When using the "Example for AppsFlyerAdobeExtension" application - execute the `pod install` command  in the `AppsFlyerAdobeExtension/Example` folder in order to install all the relevant pod dependancies.  

## <a id="analyticsPostback"> Attribution Data tracking with Adobe Analytics
Checking the "Send attribution data to Adobe Analytics" toggle on the [Configurations Dashboard](#Initialisation) will automatically send AppsFlyer Attribution data to Adobe Analytics using the `MobileCore.trackAction()` API - The data will be sent as an "*AppsFlyer Attribution Data*" Action.
All ContextData will be prefixed by the `appsflyer.` prefix, for example: `appsflyer.campaign`, `appsflyer.adset` etc.


*The Adobe Analytics Extension must be added and configured in the client Application.*
**NOTE**: Use this feature if you are only working with ad networks that allow sharing user level data with 3rd party tools.
