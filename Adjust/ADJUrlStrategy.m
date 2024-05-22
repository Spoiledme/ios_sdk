//
//  ADJUrlStrategy.m
//  Adjust
//
//  Created by Pedro S. on 11.08.20.
//  Copyright © 2020 adjust GmbH. All rights reserved.
//analytics.adjust.com


#import "ADJUrlStrategy.h"
#import "Adjust.h"
#import "ADJAdjustFactory.h"

static NSString * const kBaseAnalyticsUrl = @"https://analytics.adjust.com";
static NSString * const kBaseConsentUrl = @"https://consent.adjust.com";
static NSString * const kGdprUrl = @"https://gdpr.adjust.com";
static NSString * const kSubscriptionUrl = @"https://subscription.adjust.com";
static NSString * const kPurchaseVerificationUrl = @"https://ssrv.adjust.com";

static NSString * const kBaseAnalyticsWorldUrl = @"https://analytics.adjust.world";
static NSString * const kBaseConsentWorldUrl = @"https://consent.adjust.world";
static NSString * const kGdprWorldUrl = @"https://gdpr.adjust.world";
static NSString * const kSubscriptionWorldUrl = @"https://subscription.adjust.world";
static NSString * const kPurchaseVerificationWorldUrl = @"https://ssrv.adjust.world";

// TODO: to be utilized
static NSString * const kBaseAnalyticsIoUrl = @"https://analytics.adjust.io";
static NSString * const kBaseConsentIoUrl = @"https://consent.adjust.io";
static NSString * const kGdprIoUrl = @"https://gdpr.adjust.io";
static NSString * const kSubscriptionIoUrl = @"https://subscription.adjust.io";
static NSString * const kPurchaseVerificationIoUrl = @"https://ssrv.adjust.io";

// TODO: remove testServerCustomEndPointKey
static NSString *const testServerCustomEndPointKey = @"test_server_custom_end_point";
static NSString *const testServerAdjustEndPointKey = @"test_server_adjust_end_point";


@interface ADJUrlStrategy ()

@property (nonatomic, copy) NSMutableArray<NSString *> *baseUrlAnalyticsChoicesArray;

@property (nonatomic, copy) NSMutableArray<NSString *> *baseUrlConsentChoicesArray;

@property (nonatomic, copy) NSMutableArray<NSString *> *gdprUrlChoicesArray;

@property (nonatomic, copy) NSMutableArray<NSString *> *subscriptionUrlChoicesArray;

@property (nonatomic, copy) NSMutableArray<NSString *> *purchaseVerificationUrlChoicesArray;

@property (nonatomic, copy) NSString *testUrlOverwrite;

@property (nonatomic, assign) BOOL wasLastAttemptSuccess;

@property (nonatomic, assign) NSUInteger choiceIndex;

@property (nonatomic, assign) NSUInteger startingChoiceIndex;

@end

@implementation ADJUrlStrategy

- (instancetype)initWithUrlStrategyDomains:(NSArray *)domains
                                 extraPath:(NSString *)extraPath
                             useSubdomains:(BOOL)useSubdomains {
    self = [super init];

    _extraPath = extraPath ?: @"";

    _baseUrlAnalyticsChoicesArray = [NSMutableArray array];
    _baseUrlConsentChoicesArray = [NSMutableArray array];
    _gdprUrlChoicesArray = [NSMutableArray array];
    _subscriptionUrlChoicesArray = [NSMutableArray array];
    _purchaseVerificationUrlChoicesArray = [NSMutableArray array];

    if (domains != nil) {
        if (useSubdomains == YES) {
            for (NSString *domain in domains) {
                NSString *baseAnalyticsUrl = [ADJUrlStrategy generateBaseAnalyticsUrlForDomain:domain];
                NSString *baseConsentUrl = [ADJUrlStrategy generateBaseConsentUrlForDomain:domain];
                NSString *gdprUrl = [ADJUrlStrategy generateGdprUrlForDomain:domain];
                NSString *subscriptionUrl = [ADJUrlStrategy generateSubscriptionUrlForDomain:domain];
                NSString *purchaseVerificationUrl = [ADJUrlStrategy generatePurchaseVerificationUrlForDomain:domain];

                if ([_baseUrlAnalyticsChoicesArray containsObject:baseAnalyticsUrl] == NO) {
                    [_baseUrlAnalyticsChoicesArray addObject:baseAnalyticsUrl];
                }
                if ([_baseUrlConsentChoicesArray containsObject:baseConsentUrl] == NO) {
                    [_baseUrlConsentChoicesArray addObject:baseConsentUrl];
                }
                if ([_gdprUrlChoicesArray containsObject:gdprUrl] == NO) {
                    [_gdprUrlChoicesArray addObject:gdprUrl];
                }
                if ([_subscriptionUrlChoicesArray containsObject:subscriptionUrl] == NO) {
                    [_subscriptionUrlChoicesArray addObject:subscriptionUrl];
                }
                if ([_purchaseVerificationUrlChoicesArray containsObject:purchaseVerificationUrl] == NO) {
                    [_purchaseVerificationUrlChoicesArray addObject:purchaseVerificationUrl];
                }
            }
        } else {
            for (NSString *domain in domains) {
                NSString *domainUrl = [NSString stringWithFormat:@"https://%@", domain];

                if ([_baseUrlAnalyticsChoicesArray containsObject:domainUrl] == NO) {
                    [_baseUrlAnalyticsChoicesArray addObject:domainUrl];
                }
                if ([_baseUrlConsentChoicesArray containsObject:domainUrl] == NO) {
                    [_baseUrlConsentChoicesArray addObject:domainUrl];
                }
                if ([_gdprUrlChoicesArray containsObject:domainUrl] == NO) {
                    [_gdprUrlChoicesArray addObject:domainUrl];
                }
                if ([_subscriptionUrlChoicesArray containsObject:domainUrl] == NO) {
                    [_subscriptionUrlChoicesArray addObject:domainUrl];
                }
                if ([_purchaseVerificationUrlChoicesArray containsObject:domainUrl] == NO) {
                    [_purchaseVerificationUrlChoicesArray addObject:domainUrl];
                }
            }
        }
    } else {
        [_baseUrlConsentChoicesArray addObject:kBaseConsentUrl];
        [_baseUrlConsentChoicesArray addObject:kBaseConsentWorldUrl];
        // [_baseUrlConsentChoicesArray addObject:kBaseConsentIoUrl];
        [_baseUrlAnalyticsChoicesArray addObject:kBaseAnalyticsUrl];
        [_baseUrlAnalyticsChoicesArray addObject:kBaseAnalyticsWorldUrl];
        // [_baseUrlAnalyticsChoicesArray addObject:kBaseAnalyticsIoUrl];
        [_gdprUrlChoicesArray addObject:kGdprUrl];
        [_gdprUrlChoicesArray addObject:kGdprWorldUrl];
        // [_gdprUrlChoicesArray addObject:kGdprIoUrl];
        [_subscriptionUrlChoicesArray addObject:kSubscriptionUrl];
        [_subscriptionUrlChoicesArray addObject:kSubscriptionWorldUrl];
        // [_subscriptionUrlChoicesArray addObject:kSubscriptionIoUrl];
        [_purchaseVerificationUrlChoicesArray addObject:kPurchaseVerificationUrl];
        [_purchaseVerificationUrlChoicesArray addObject:kPurchaseVerificationWorldUrl];
        // [_purchaseVerificationUrlChoicesArray addObject:kPurchaseVerificationIoUrl];
    }

    _testUrlOverwrite = [ADJAdjustFactory testUrlOverwrite];
    _wasLastAttemptSuccess = NO;
    _choiceIndex = 0;
    _startingChoiceIndex = 0;

    return self;
}

+ (NSString *)generateBaseAnalyticsUrlForDomain:(NSString *)domain {
    return [NSString stringWithFormat:@"https://analytics.%@", domain];
}

+ (NSString *)generateBaseConsentUrlForDomain:(NSString *)domain {
    return [NSString stringWithFormat:@"https://consent.%@", domain];
}

+ (NSString *)generateGdprUrlForDomain:(NSString *)domain {
    return [NSString stringWithFormat:@"https://gdpr.%@", domain];
}

+ (NSString *)generateSubscriptionUrlForDomain:(NSString *)domain {
    return [NSString stringWithFormat:@"https://subscription.%@", domain];
}

+ (NSString *)generatePurchaseVerificationUrlForDomain:(NSString *)domain {
    return [NSString stringWithFormat:@"https://ssrv.%@", domain];
}

- (nonnull NSString *)urlForActivityKind:(ADJActivityKind)activityKind
                          isConsentGiven:(BOOL)isConsentGiven
                       withSendingParams:(NSMutableDictionary *)sendingParams {
    NSString *_Nonnull urlByActivityKind = [self urlForActivityKind:activityKind
                                                     isConsentGiven:isConsentGiven];

    if (self.testUrlOverwrite != nil) {
        [sendingParams setObject:urlByActivityKind
                          forKey:testServerAdjustEndPointKey];
        return self.testUrlOverwrite;
    }

    return urlByActivityKind;
}

- (nonnull NSString *)urlForActivityKind:(ADJActivityKind)activityKind
                          isConsentGiven:(BOOL)isConsentGiven {
    if (activityKind == ADJActivityKindGdpr) {
        return [self.gdprUrlChoicesArray objectAtIndex:self.choiceIndex];
    }

    if (activityKind == ADJActivityKindSubscription) {
        return [self.subscriptionUrlChoicesArray objectAtIndex:self.choiceIndex];
    }

    if (activityKind == ADJActivityKindPurchaseVerification) {
        return [self.purchaseVerificationUrlChoicesArray objectAtIndex:self.choiceIndex];
    }

    if (isConsentGiven) {
        return [self.baseUrlConsentChoicesArray objectAtIndex:self.choiceIndex];
    } else {
        return [self.baseUrlAnalyticsChoicesArray objectAtIndex:self.choiceIndex];
    }
}

- (void)resetAfterSuccess {
    self.startingChoiceIndex = self.choiceIndex;
    self.wasLastAttemptSuccess = YES;
}

- (BOOL)shouldRetryAfterFailure:(ADJActivityKind)activityKind {
    self.wasLastAttemptSuccess = NO;

    NSUInteger choiceListSize;
    if (activityKind == ADJActivityKindGdpr) {
        choiceListSize = [self.gdprUrlChoicesArray count];
    } else if (activityKind == ADJActivityKindSubscription) {
        choiceListSize = [self.subscriptionUrlChoicesArray count];
    } else if (activityKind == ADJActivityKindPurchaseVerification) {
        choiceListSize = [self.purchaseVerificationUrlChoicesArray count];
    } else {
        // baseUrlConsentChoicesArray or baseUrlAnalyticsChoicesArray should be of equal size
        choiceListSize = [self.baseUrlConsentChoicesArray count];
    }

    NSUInteger nextChoiceIndex = (self.choiceIndex + 1) % choiceListSize;
    self.choiceIndex = nextChoiceIndex;
    BOOL nextChoiceHasNotReturnedToStartingChoice = self.choiceIndex != self.startingChoiceIndex;

    return nextChoiceHasNotReturnedToStartingChoice;
}

@end
