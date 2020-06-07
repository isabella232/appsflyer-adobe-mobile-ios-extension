# API

<img src="https://massets.appsflyer.com/wp-content/uploads/2018/06/20092440/static-ziv_1TP.png"  width="400" >


- [registerExtension](#registerExtension)
- [registerAppsFlyerExtensionCallbacks](#registerAppsFlyerExtensionCallbacks)


---

 ##### <a id="registerExtension"> **`+ (void)registerExtension`**

Register the AppsFlyer-Adobe Extension


*Example:*

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ...
    [ACPCore configureWithAppId:@"launc-key"];
    ...
    [AppsFlyerAdobeExtension registerExtension];
    ...
    return YES;
}


```

---


 ##### <a id="registerAppsFlyerExtensionCallbacks"> **`+ (void)registerCallbacks:(void (^)(NSDictionary *dictionary))completionHandler`**
 

| parameter          | type                        | description  |
| -----------        |-----------------------------|--------------|
| `completionHandler` | `void (^)(NSDictionary *dictionary)` | AppsFlyer Deeplink interface|

*Example:*

```objc

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    ...
    
    [AppsFlyerAdobeExtension registerCallbacks:^(NSDictionary *dictionary) {
        NSLog(@"[AppsFlyerAdobeExtension] Received callback: %@", dictionary);
        if([[dictionary objectForKey:@"callback_type"] isEqualToString:@"onConversionDataReceived"]){
            if([[dictionary objectForKey:@"is_first_launch"] boolValue] == YES){
                NSString* af_status = [dictionary objectForKey:@"af_status"];
                if([af_status isEqualToString:@"Non-organic"]){
                    NSLog(@"this is first launch and a non organic install!");
                }
            }
        } else if([[dictionary objectForKey:@"callback_type"] isEqualToString:@"onAppOpenAttribution"]) {
            NSLog(@"onAppOpenAttribution Received");
        }
     }];

    [AppsFlyerAdobeExtension callbacksErrorHandler:^(NSError *error) {
          NSLog(@"[AppsFlyerAdobeExtension] Error receivng callback: %@" , error);
      }];
    
    return YES;
}

```

