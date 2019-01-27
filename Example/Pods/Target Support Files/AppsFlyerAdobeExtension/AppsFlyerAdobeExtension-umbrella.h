#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AppsFlyerAdobeExtension.h"
#import "AppsFlyerEventListener.h"
#import "AppsFlyerSharedStateListener.h"

FOUNDATION_EXPORT double AppsFlyerAdobeExtensionVersionNumber;
FOUNDATION_EXPORT const unsigned char AppsFlyerAdobeExtensionVersionString[];

