//
//  AppsFlyerAdobeExtension.m
//  appsflyer-adobe-extension
//
//  Created by Benjamin Winestein on 05/08/2018.
//  Copyright © 2018 Benjamin Winestein. All rights reserved.
//

#import "AppsFlyerAdobeExtension.h"

static AppsFlyerAdobeExtension *__sharedInstance = nil;
static void (^__completionHandler)(NSDictionary*) = nil;
static void (^__errorHandler)(NSError*) = nil;

@implementation AppsFlyerAdobeExtension

- (instancetype)init {
    if (self = [super init]) {
        
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            __sharedInstance = self;
        });
        
        _didReceiveConfigurations = NO;
        _didInit = NO;
        _trackAttributionData = NO;
        _eventSettings = @"action";
        
        NSError* error = nil;
        
        // Listener/Dispatcher for shared state events
        if ([self.api registerListener:[AppsFlyerSharedStateListener class]
                             eventType:@"com.adobe.eventType.hub"
                           eventSource:@"com.adobe.eventSource.sharedState"
                                 error:&error]) {
            NSLog(@"com.appsflyer.adobeextension Shared State listener was registered");
        }
        else if (error) {
            NSLog(@"com.appsflyer.adobeextension Error while registering shared state listener!!\n%@ %ld", [error domain], [error code]);
        }
        
        // Listener for Analytics Event binding
        if ([self.api registerListener:[AppsFlyerEventListener class]
                             eventType:@"com.adobe.eventType.generic.track"
                           eventSource:@"com.adobe.eventSource.requestContent"
                                 error:&error]) {
            NSLog(@"com.appsflyer.adobeextension Analytics Events listener was registered");
        }
        else if (error) {
            NSLog(@"com.appsflyer.adobeextension Error while registering Analytics Events listener!!\n%@ %d", [error domain], (int)[error code]);
        }
    }
    return self;
}

- (NSString*) name {
    return @"com.appsflyer.adobeextension";
}

+ (instancetype)shared {
    if (__sharedInstance) {
        return __sharedInstance;
    }
    else {
        NSLog(@"com.appsflyer.adobeextension was not initialised");
        return nil;
    }
}

+ (void)registerExtension {
    NSError* error = nil;
    if ([ACPCore registerExtension: [AppsFlyerAdobeExtension class] error: &error]) {
        NSLog(@"com.appsflyer.adobeextension was registered");
    }
    else {
        NSLog(@"Error registering com.appsflyer.adobeextension: %@ %d", [error domain], (int)[error code]);
    }
}

- (void)unregister {
    [[self api] unregisterExtension];
}

- (void)onUnregister {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    __sharedInstance = nil;
    
    NSLog(@"com.appsflyer.adobeextension was unregistered");
}

- (void)unexpectedError : (nonnull NSError*) error {
//    [super unexpectedError];
    NSLog(@"com.appsflyer.adobeextension unexpectedError %@", error);
}

- (void)setupAppsFlyerTrackingWithAppId:(NSString*)appId appsFlyerDevKey:(NSString*)appsFlyerDevKey
                                isDebug:(BOOL)isDebug trackAttrData:(BOOL)trackAttrData
                                eventSettings:(nonnull NSString *)eventSettings {
    if (appId != nil && appsFlyerDevKey != nil) {
        if (![self didReceiveConfigurations]) {
            
            [ACPIdentity getExperienceCloudId:^(NSString * _Nullable retrievedCloudId) {
                if (retrievedCloudId) {
                    [[AppsFlyerTracker sharedTracker] setCustomerUserID:retrievedCloudId];
                } else {
                    NSLog(@"com.appsflyer.adobeextension ExperienceCloudId is null");
                }
            }];
            
            [AppsFlyerTracker sharedTracker].appleAppID = appId;
            [AppsFlyerTracker sharedTracker].appsFlyerDevKey = appsFlyerDevKey;
            [AppsFlyerTracker sharedTracker].delegate = self;
            [AppsFlyerTracker sharedTracker].isDebug = isDebug;
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
            
            [self setTrackAttributionData:trackAttrData];
            [self setEventSettings: eventSettings];
            [self setDidReceiveConfigurations:YES];
            
            if (![self didInit]) {
                [[AppsFlyerTracker sharedTracker] trackAppLaunch];
                [self setDidInit:YES];
            }
        } else {
            NSLog(@"com.appsflyer.adobeextension rejecting re-init of previously initialized tracker");
        }
    }
}

- (void) appDidBecomeActive {
    if ([self didReceiveConfigurations]) {
        [[AppsFlyerTracker sharedTracker] trackAppLaunch];
        [self setDidInit:YES];
    }
}

+ (void)continueUserActivity:(NSUserActivity *)userActivity
            restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> *restorableObjects))restorationHandler {
    [[AppsFlyerTracker sharedTracker] continueUserActivity:userActivity restorationHandler:restorationHandler];
}

+ (void)openURL:(NSURL *)url options:(NSDictionary *)options {
    [[AppsFlyerTracker sharedTracker] handleOpenUrl:url options:options];
}

- (void) onAppOpenAttribution:(NSDictionary *)attributionData {
    NSMutableDictionary* appendedAttributionData = [NSMutableDictionary dictionaryWithDictionary:attributionData];
    [appendedAttributionData setObject:@"onAppOpenAttribution" forKey:@"callback_type"];
    [ACPCore trackAction:@"AppsFlyer Engagement Data" data:[self setKeyPrefix:[self setKeyPrefixOnAppOpenAttribution:attributionData]]];
    if (__completionHandler) {
        __completionHandler(appendedAttributionData);
    }
}

- (NSString*) getEventSettings {
    return _eventSettings;
}

- (void) onAppOpenAttributionFailure:(NSError *)error {
    if (__errorHandler) {
        __errorHandler(error);
    }
}

- (void)onConversionDataSuccess:(nonnull NSDictionary *)installData {
    
    NSMutableDictionary* appendedInstallData = [NSMutableDictionary dictionaryWithDictionary:installData];

    
    if (_trackAttributionData) {
        id isFirstData = [installData objectForKey:@"is_first_launch"];
        BOOL firstData = [isFirstData isKindOfClass:[NSNumber class]] && [isFirstData integerValue] == 1;
        if (firstData) {
            
            NSError* error = nil;
            if (![self.api setSharedEventState:[self getSaredEventState:installData] event:nil error:&error] && error) {
                NSLog(@"Error setting shared state %@:%ld", [error domain], [error code]);
            }
            
            NSString* appsflyer_id = [[AppsFlyerTracker sharedTracker] getAppsFlyerUID];
            [appendedInstallData setObject:appsflyer_id forKey:@"appsflyer_id"];
            [ACPCore trackAction:@"AppsFlyer Attribution Data" data:[self setKeyPrefix:appendedInstallData]];
        }
    }
    
    
    [appendedInstallData setObject:@"onConversionDataReceived" forKey:@"callback_type"];
    
    if (__completionHandler) {
        __completionHandler(appendedInstallData);
    }
}

- (void)onConversionDataFail:(nonnull NSError *)error {
    if (__errorHandler) {
        __errorHandler(error);
    }
}

+ (void)registerCallbacks:(void (^)(NSDictionary *dictionary))completionHandler {
    __completionHandler = completionHandler;
}

+ (void)callbacksErrorHandler:(void (^) (NSError *error))errorHandler {
    __errorHandler = errorHandler;
}

-(NSMutableDictionary *) setKeyPrefix:(NSDictionary *)attributionData {
    NSMutableDictionary* withPrefix = [[NSMutableDictionary alloc] init];
    for(id key in attributionData) {
        if (![key isEqualToString:@"callback_type"]) {
            NSString* newKey = [NSString stringWithFormat: @"%@%@", @"appsflyer.", key];
            NSString* newValue = [NSString stringWithFormat: @"%@", [attributionData objectForKey:key]];
            [withPrefix setObject:newValue  forKey:newKey];
        }
    }
    return withPrefix;
}

-(NSMutableDictionary *) setKeyPrefixOnAppOpenAttribution:(NSDictionary *)attributionData {
    NSMutableDictionary* withPrefix = [[NSMutableDictionary alloc] init];
    for(id key in attributionData) {
        if (![key isEqualToString:@"callback_type"]) {
            NSString* newKey = [NSString stringWithFormat: @"%@%@", @"af_engagement_", key];
            NSString* newValue = [NSString stringWithFormat: @"%@", [attributionData objectForKey:key]];
            [withPrefix setObject:newValue  forKey:newKey];
        }
    }
    return withPrefix;
}

-(NSMutableDictionary *) getSaredEventState:(NSDictionary *)attributionData {
    NSMutableDictionary* sharedEventState = [attributionData mutableCopy];
    NSString* appsflyer_id = [[AppsFlyerTracker sharedTracker] getAppsFlyerUID];
    NSString* sdk_verision = [[AppsFlyerTracker sharedTracker] getSDKVersion];
    
    [sharedEventState setObject:appsflyer_id  forKey:APPSFLYER_ID];
    [sharedEventState setObject:sdk_verision  forKey:SDK_VERSION];
    
    if(![sharedEventState objectForKey:MEDIA_SOURCE]){
        [sharedEventState setObject:@"organic"  forKey:MEDIA_SOURCE];
    }
    
    [sharedEventState removeObjectForKey:CALLBACK_TYPE];
    [sharedEventState removeObjectForKey:IS_FIRST_LAUNCH];

    return sharedEventState;
}

@end
