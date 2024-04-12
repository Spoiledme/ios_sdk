//
//  AdjustConfig.m
//  adjust
//
//  Created by Pedro Filipe on 30/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "ADJConfig.h"
#import "ADJAdjustFactory.h"
#import "ADJLogger.h"
#import "ADJUtil.h"
#import "Adjust.h"

@interface ADJConfig()

@property (nonatomic, weak) id<ADJLogger> logger;

@end

@implementation ADJConfig

+ (ADJConfig *)configWithAppToken:(NSString *)appToken
                      environment:(NSString *)environment {
    return [[ADJConfig alloc] initWithAppToken:appToken environment:environment];
}

+ (ADJConfig *)configWithAppToken:(NSString *)appToken
                      environment:(NSString *)environment
             allowSuppressLogLevel:(BOOL)allowSuppressLogLevel {
    return [[ADJConfig alloc] initWithAppToken:appToken environment:environment allowSuppressLogLevel:allowSuppressLogLevel];
}

- (id)initWithAppToken:(NSString *)appToken
           environment:(NSString *)environment {
    return [self initWithAppToken:appToken
                      environment:environment
             allowSuppressLogLevel:NO];
}

- (id)initWithAppToken:(NSString *)appToken
           environment:(NSString *)environment
  allowSuppressLogLevel:(BOOL)allowSuppressLogLevel {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.logger = ADJAdjustFactory.logger;

    if (allowSuppressLogLevel && [ADJEnvironmentProduction isEqualToString:environment]) {
        [self setLogLevel:ADJLogLevelSuppress environment:environment];
    } else {
        [self setLogLevel:ADJLogLevelInfo environment:environment];
    }

    if (![self checkEnvironment:environment]) {
        return self;
    }
    if (![self checkAppToken:appToken]) {
        return self;
    }

    _appToken = appToken;
    _environment = environment;
    
    // default values
    self.sendInBackground = NO;
    self.coppaCompliantEnabled = NO;
    self.allowIdfaReading = YES;
    self.allowAdServicesInfoReading = YES;
    _isLinkMeEnabled = NO;
    _isSKAdNetworkHandlingActive = YES;

    return self;
}

- (void)setLogLevel:(ADJLogLevel)logLevel {
    [self setLogLevel:logLevel environment:self.environment];
}

- (void)setLogLevel:(ADJLogLevel)logLevel
        environment:(NSString *)environment {
    [self.logger setLogLevel:logLevel
     isProductionEnvironment:[ADJEnvironmentProduction isEqualToString:environment]];
}

- (void)deactivateSKAdNetworkHandling {
    _isSKAdNetworkHandlingActive = NO;
}

- (void)enableLinkMe {
    _isLinkMeEnabled = YES;
}

- (void)setDelegate:(NSObject<AdjustDelegate> *)delegate {
    BOOL hasResponseDelegate = NO;
    BOOL implementsDeeplinkCallback = NO;

    if ([ADJUtil isNull:delegate]) {
        [self.logger warn:@"Delegate is nil"];
        _delegate = nil;
        return;
    }

    if ([delegate respondsToSelector:@selector(adjustAttributionChanged:)]) {
        [self.logger debug:@"Delegate implements adjustAttributionChanged:"];
        hasResponseDelegate = YES;
    }

    if ([delegate respondsToSelector:@selector(adjustEventTrackingSucceeded:)]) {
        [self.logger debug:@"Delegate implements adjustEventTrackingSucceeded:"];
        hasResponseDelegate = YES;
    }

    if ([delegate respondsToSelector:@selector(adjustEventTrackingFailed:)]) {
        [self.logger debug:@"Delegate implements adjustEventTrackingFailed:"];
        hasResponseDelegate = YES;
    }

    if ([delegate respondsToSelector:@selector(adjustSessionTrackingSucceeded:)]) {
        [self.logger debug:@"Delegate implements adjustSessionTrackingSucceeded:"];
        hasResponseDelegate = YES;
    }

    if ([delegate respondsToSelector:@selector(adjustSessionTrackingFailed:)]) {
        [self.logger debug:@"Delegate implements adjustSessionTrackingFailed:"];
        hasResponseDelegate = YES;
    }

    if ([delegate respondsToSelector:@selector(adjustDeeplinkResponse:)]) {
        [self.logger debug:@"Delegate implements adjustDeeplinkResponse:"];
        // does not enable hasDelegate flag
        implementsDeeplinkCallback = YES;
    }
    
    if ([delegate respondsToSelector:@selector(adjustConversionValueUpdated:)]) {
        [self.logger debug:@"Delegate implements adjustConversionValueUpdated:"];
        hasResponseDelegate = YES;
    }

    if (!(hasResponseDelegate || implementsDeeplinkCallback)) {
        [self.logger error:@"Delegate does not implement any optional method"];
        _delegate = nil;
        return;
    }

    _delegate = delegate;
}

- (BOOL)checkEnvironment:(NSString *)environment {
    if ([ADJUtil isNull:environment]) {
        [self.logger error:@"Missing environment"];
        return NO;
    }
    if ([environment isEqualToString:ADJEnvironmentSandbox]) {
        [self.logger warnInProduction:@"SANDBOX: Adjust is running in Sandbox mode. Use this setting for testing. Don't forget to set the environment to `production` before publishing"];
        return YES;
    } else if ([environment isEqualToString:ADJEnvironmentProduction]) {
        [self.logger warnInProduction:@"PRODUCTION: Adjust is running in Production mode. Use this setting only for the build that you want to publish. Set the environment to `sandbox` if you want to test your app!"];
        return YES;
    }
    [self.logger error:@"Unknown environment '%@'", environment];
    return NO;
}

- (BOOL)checkAppToken:(NSString *)appToken {
    if ([ADJUtil isNull:appToken]) {
        [self.logger error:@"Missing App Token"];
        return NO;
    }
    if (appToken.length != 12) {
        [self.logger error:@"Malformed App Token '%@'", appToken];
        return NO;
    }
    return YES;
}

- (BOOL)isValid {
    return self.appToken != nil;
}

- (id)copyWithZone:(NSZone *)zone {
    ADJConfig *copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy->_appToken = [self.appToken copyWithZone:zone];
        copy->_environment = [self.environment copyWithZone:zone];
        copy.logLevel = self.logLevel;
        copy.sdkPrefix = [self.sdkPrefix copyWithZone:zone];
        copy.defaultTracker = [self.defaultTracker copyWithZone:zone];
        copy.sendInBackground = self.sendInBackground;
        copy.allowIdfaReading = self.allowIdfaReading;
        copy.allowAdServicesInfoReading = self.allowAdServicesInfoReading;
        copy.delayStart = self.delayStart;
        copy.attConsentWaitingInterval = self.attConsentWaitingInterval;
        copy.coppaCompliantEnabled = self.coppaCompliantEnabled;
        copy.externalDeviceId = [self.externalDeviceId copyWithZone:zone];
        copy.needsCost = self.needsCost;
        copy->_isSKAdNetworkHandlingActive = self.isSKAdNetworkHandlingActive;
        copy->_urlStrategy = [self.urlStrategy copyWithZone:zone];
        copy->_isLinkMeEnabled = self.isLinkMeEnabled;
        copy.readDeviceInfoOnceEnabled = self.readDeviceInfoOnceEnabled;
        // adjust delegate not copied
    }

    return copy;
}

@end
