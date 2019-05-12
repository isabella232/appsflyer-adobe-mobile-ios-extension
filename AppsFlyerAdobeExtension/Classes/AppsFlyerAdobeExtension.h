//
//  AppsFlyerAdobeExtension.h
//  appsflyer-adobe-extension
//
//  Created by Benjamin Winestein on 05/08/2018.
//  Copyright © 2018 Benjamin Winestein. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ACPCore/ACPCore.h>
#import <ACPCore/ACPExtension.h>
#import <ACPCore/ACPIdentity.h>
#import "AppsFlyerEventListener.h"
#import "AppsFlyerSharedStateListener.h"
#import <AppsFlyerLib/AppsFlyerTracker.h>

NS_ASSUME_NONNULL_BEGIN
@interface AppsFlyerAdobeExtension : ACPExtension <AppsFlyerTrackerDelegate> {}

@property (atomic) BOOL didReceiveConfigurations;
@property (atomic) BOOL didInit;
@property (atomic) BOOL trackAttributionData;

+ (nullable instancetype)shared;
+ (void)registerExtension;
- (NSString*)name;
- (void)unregister;
- (void)onUnregister;
- (void)unexpectedError: (NSError*) error;

- (void)setupAppsFlyerTrackingWithAppId:(NSString*)appId appsFlyerDevKey:(NSString*)appsFlyerDevKey isDebug:(BOOL)isDebug trackAttrData:(BOOL)trackAttrData;
+ (void)registerCallbacks:(void (^ _Nullable)(NSDictionary *dictionary))completionHandler;
+ (void)callbacksErrorHandler:(void (^ _Nullable)(NSError *error))errorHandler;
- (NSMutableDictionary*)setKeyPrefix:(NSDictionary *)attributionData;

+ (void)continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> *restorableObjects))restorationHandler;
+ (void)openURL:(NSURL *)url options:(NSDictionary *)options;

@end
NS_ASSUME_NONNULL_END
