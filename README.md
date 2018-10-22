

# AppsFlyer SDK Extension for Adobe Mobile SDK

[![Version](https://img.shields.io/cocoapods/v/AppsFlyerAdobeExtension.svg?style=flat)](https://cocoapods.org/pods/AppsFlyerAdobeExtension)
[![Platform](https://img.shields.io/cocoapods/p/AppsFlyerAdobeExtension.svg?style=flat)](https://cocoapods.org/pods/AppsFlyerAdobeExtension)

## Installation

For instructions on using AppsFlyer's Adobe Mobile SDK Extension please see: https://aep-sdks.gitbook.io/docs/getting-started/create-a-mobile-property

After adding the extension to the mobile property, please set the App ID and Dev Key fields and save the extension settings. 
![AppsFlyerAdobeSDK](https://github.com/AppsFlyerSDK/AppsFlyerAdobeExtension/blob/master/gitresources/img.png)
For more information on adding applications to the AppsFlyer dashboard see [here](https://support.appsflyer.com/hc/en-us/articles/207377436-Adding-a-New-App-to-the-AppsFlyer-Dashboard)

Information on adding the extension to xCode is available on the Launch dashboard.

## Extension Callbacks
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

----
