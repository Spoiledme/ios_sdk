//
//  ADJConstants.m
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJConstants.h"

double const ADJSecondToMilliDouble = 1000.0;
NSUInteger const ADJMilliToMicro = 1000;
NSUInteger const ADJMilliToNano = 1000000;

NSUInteger const ADJOneSecondMilli = 1000;
NSUInteger const ADJTenSecondsMilli = ADJOneSecondMilli * 10;
NSUInteger const ADJOneMinuteMilli = ADJOneSecondMilli * 60;
NSUInteger const ADJThirtyMinutesMilli = ADJOneMinuteMilli * 30;
NSUInteger const ADJOneHourMilli = ADJOneMinuteMilli * 60;

NSString *const ADJAdjustSubSystem = @"com.adjust.sdk";
NSString *const ADJAdjustCategory = @"Adjust";

NSString *const ADJAppAdjustUrl = @"https://app.adjust.com";
NSString *const ADJGdprAdjustUrl = @"https://gdpr.adjust.com";
NSString *const ADJSubscriptionAdjustUrl = @"https://subscription.adjust.com";

NSUInteger const ADJInitialHashCode = 17;
NSUInteger const ADJHashCodeMultiplier = 37;

NSUInteger const ADJDefaultMaxCapacityEventDeduplication = 10;

// IoData metadata
NSString *const ADJMetadataVersionKey = @"METADATA_VERSION";
NSString *const ADJMetadataVersionValue = @"5.0.0";
NSString *const ADJMetadataIoDataTypeKey = @"METADATA_IO_DATA_TYPE";
NSString *const ADJMetadataMapName = @"0_METADATA_MAP_TYPE";
NSString *const ADJPropertiesMapName = @"1_PROPERTIES_MAP_TYPE";

// default starting states
const BOOL ADJIsSdkPausedWhenStarting = YES;
const BOOL ADJIsSdkInForegroundWhenStarting = NO;
const BOOL ADJIsSdkActiveWhenStarting = YES;
const BOOL ADJIsSdkForgottenWhenStarting = NO;
const BOOL ADJIsSdkOfflineWhenStarting = NO;
const BOOL ADJIsNetworkReachableWhenStarting = YES;

// logging
NSString *const ADJLogWhereKey = @"where";
NSString *const ADJLogSubjectKey = @"subject";
NSString *const ADJLogWhyKey = @"why";
NSString *const ADJLogExpectedKey = @"expected";
NSString *const ADJLogActualKey = @"actual";
NSString *const ADJLogFailMessageKey = @"fail_message";
NSString *const ADJLogValueKey = @"value";
NSString *const ADJLogFromKey = @"from";
NSString *const ADJLogValueNameKey = @"value_name";
