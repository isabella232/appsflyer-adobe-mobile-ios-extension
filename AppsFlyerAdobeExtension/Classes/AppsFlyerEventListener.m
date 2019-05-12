//
//  AppsFlyerEvents.m
//  appsflyer-adobe-extension
//
//  Created by Benjamin Winestein on 21/08/2018.
//  Copyright © 2018 Benjamin Winestein. All rights reserved.
//

#import "AppsFlyerEventListener.h"
#import <AppsFlyerLib/AppsFlyerTracker.h>

@implementation AppsFlyerEventListener

- (instancetype)init {
    self = [super init];
    if (self) {
        NSLog(@"com.appsflyer.adobeextension Analytics Events listener was initialized");
    }
    return self;
}

- (void)hear:(nonnull ACPExtensionEvent*)event {
    if ([[event eventType] isEqualToString:@"com.adobe.eventType.generic.track"] && [[event eventSource] isEqualToString:@"com.adobe.eventSource.requestContent"]) {
        NSDictionary* eventData = [NSDictionary dictionaryWithDictionary:[event eventData]];
        NSDictionary* nestedData = [eventData objectForKey:@"contextdata"];
        NSString* eventName = [eventData objectForKey:@"action"];
        
        if ([eventName isEqualToString:@"AppsFlyer Attribution Data"]) {
            NSLog(@"com.appsflyer.adobeextension Discarding event binding for AppsFlyer Attribution Data event");
            return;
        }
        
        NSNumber* revenue = [self extractRevenue:nestedData withKey:@"revenue"];
        NSString* currency = [self extractCurrency:nestedData withKey:@"currency"];
        
        if (revenue) {
            NSMutableDictionary* af_payload_properties = [NSMutableDictionary dictionaryWithDictionary: nestedData];
            [af_payload_properties setObject:revenue forKey:@"af_revenue"];

            if (currency) {
                [af_payload_properties setObject:currency forKey:@"af_currency"];
            }
            // Track event with af_revenue ( + af_currency if set)
           [[AppsFlyerTracker sharedTracker] trackEvent:eventName withValues:af_payload_properties];
        } else {
            // Track the raw event.
            if (eventName != nil && [eventName isKindOfClass:[NSString class]]) {
                [[AppsFlyerTracker sharedTracker] trackEvent:eventName withValues:nestedData];
            }
        }
    }
}
    
- (NSString *)extractCurrency:(NSDictionary *)dictionary withKey:(NSString *)currencyKey {
    id currencyProperty = dictionary[currencyKey];
    if (currencyProperty) {
        if ([currencyProperty isKindOfClass:[NSString class]]) {
            return currencyProperty;
        }
    }
    // If currency not set, return default USD
    return @"USD";
}

- (NSDecimalNumber *)extractRevenue:(NSDictionary *)dictionary withKey:(NSString *)revenueKey {
    id revenueProperty = dictionary[revenueKey];
    if (revenueProperty) {
        if ([revenueProperty isKindOfClass:[NSString class]]) {
            return [NSDecimalNumber decimalNumberWithString:revenueProperty];
        } else if ([revenueProperty isKindOfClass:[NSNumber class]]) {
            return revenueProperty;
        }
    }
    return nil;
}

@end
