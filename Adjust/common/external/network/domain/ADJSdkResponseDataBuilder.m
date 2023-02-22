//
//  ADJSdkResponseDataBuilder.m
//  Adjust
//
//  Created by Pedro Silva on 26.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJSdkResponseDataBuilder.h"

#import "ADJUtilF.h"
#import "ADJAttributionPackageData.h"
#import "ADJAttributionResponseData.h"
#import "ADJBillingSubscriptionPackageData.h"
#import "ADJBillingSubscriptionResponseData.h"
#import "ADJClickPackageData.h"
#import "ADJClickResponseData.h"
#import "ADJGdprForgetPackageData.h"
#import "ADJGdprForgetResponseData.h"
#import "ADJLogPackageData.h"
#import "ADJLogResponseData.h"
#import "ADJSessionPackageData.h"
#import "ADJSessionResponseData.h"
#import "ADJEventPackageData.h"
#import "ADJEventResponseData.h"
#import "ADJAdRevenuePackageData.h"
#import "ADJAdRevenueResponseData.h"
#import "ADJInfoResponseData.h"
#import "ADJInfoPackageData.h"
#import "ADJThirdPartySharingPackageData.h"
#import "ADJThirdPartySharingResponseData.h"
#import "ADJMeasurementConsentPackageData.h"
#import "ADJMeasurementConsentResponseData.h"
#import "ADJUnknownResponseData.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) id<ADJSdkPackageData> sourcePackage;
 @property (nonnull, readonly, strong, nonatomic) ADJStringMapBuilder *sendingParameters;
 @property (nonnull, readonly, strong, nonatomic) id<ADJSdkResponseCallbackSubscriber> sourceCallback;
 @property (nullable, readwrite, strong, nonatomic) NSDictionary *jsonDictionary;
 */

@interface ADJSdkResponseDataBuilder ()
#pragma mark - Injected dependencies

#pragma mark - Internal variables
@property (readwrite, assign, nonatomic) NSUInteger retries;

@end

@implementation ADJSdkResponseDataBuilder
#pragma mark Instantiation
- (nonnull instancetype)initWithSourceSdkPackage:(nonnull id<ADJSdkPackageData>)sourcePackage
                               sendingParameters:(nonnull ADJStringMapBuilder *)sendingParameters
                                  sourceCallback:(nonnull id<ADJSdkResponseCallbackSubscriber>)sourceCallback {
    self = [super init];
    _sourcePackage = sourcePackage;
    _sendingParameters = sendingParameters;
    _sourceCallback = sourceCallback;
    _jsonDictionary = nil;

    return self;
}

#pragma mark Public API
- (BOOL)didReceiveJsonResponse {
    return self.jsonDictionary != nil;
}

- (void)logErrorWithLogger:(nullable ADJLogger *)logger
                   nsError:(nullable NSError *)nsError
              errorMessage:(nonnull NSString *)errorMessage
{
    if (nsError != nil) {
        if (logger != nil) {
            [logger debugWithMessage:errorMessage
                        builderBlock:^(ADJLogBuilder * _Nonnull logBuilder)
             {
                [logBuilder withError:nsError
                                issue:ADJIssueNetworkRequest];
            }];
        }
    } else {
        if (logger != nil) {
            [logger debugDev:errorMessage issueType:ADJIssueNetworkRequest];
        }
    }
}

- (void)incrementRetries {
    self.retries = self.retries + 1;
}

#define tryBuildResponse(packageClassType, responseClassType, packageDataName)  \
if ([self.sourcePackage isKindOfClass:[packageClassType class]]) {          \
return [[responseClassType alloc]                                       \
initWithBuilder:self                                        \
packageDataName:(packageClassType *)self.sourcePackage      \
logger:logger];                                             \
}                                                                           \

- (nonnull id<ADJSdkResponseData>)buildSdkResponseDataWithLogger:(nullable ADJLogger *)logger {

    tryBuildResponse(ADJGdprForgetPackageData, ADJGdprForgetResponseData, gdprForgetPackageData)
    tryBuildResponse(ADJLogPackageData, ADJLogResponseData, logPackageData)
    tryBuildResponse(ADJClickPackageData, ADJClickResponseData, clickPackageData)
    tryBuildResponse(ADJBillingSubscriptionPackageData, ADJBillingSubscriptionResponseData, billingSubscriptionPackageData)
    tryBuildResponse(ADJAttributionPackageData, ADJAttributionResponseData, attributionPackageData)
    tryBuildResponse(ADJSessionPackageData, ADJSessionResponseData, sessionPackageData)
    tryBuildResponse(ADJEventPackageData, ADJEventResponseData, eventPackageData)
    tryBuildResponse(ADJAdRevenuePackageData, ADJAdRevenueResponseData, adRevenuePackageData)
    tryBuildResponse(ADJInfoPackageData, ADJInfoResponseData, infoPackageData)
    tryBuildResponse(ADJThirdPartySharingPackageData, ADJThirdPartySharingResponseData, thirdPartySharingPackageData)
    tryBuildResponse(ADJMeasurementConsentPackageData, ADJMeasurementConsentResponseData, measurementConsentPackageData)

    if (logger != nil) {
        [logger debugDev:
         @"Could not match source sdk package, to one of the know types."
         " Will still be created with unknown type"
                     key:@"sourcePackage class"
                   value:NSStringFromClass([self.sourcePackage class])];
    }

    return [[ADJUnknownResponseData alloc] initWithBuilder:self
                                            sdkPackageData:self.sourcePackage
                                                    logger:logger];
}

@end

