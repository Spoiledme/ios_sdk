//
//  ADJClientEventData.h
//  Adjust
//
//  Created by Aditi Agrawal on 28/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJClientActionIoDataInjectable.h"
#import "ADJAdjustEvent.h"
#import "ADJIoData.h"
#import "ADJLogger.h"
#import "ADJNonEmptyString.h"
#import "ADJMoney.h"
#import "ADJStringMap.h"

// public constants
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const ADJClientEventDataMetadataTypeValue;

NS_ASSUME_NONNULL_END

@interface ADJClientEventData : NSObject<ADJClientActionIoDataInjectable>
// instantiation
+ (nullable instancetype)instanceFromClientWithAdjustEvent:(nullable ADJAdjustEvent *)adjustEvent
                                                    logger:(nonnull ADJLogger *)logger;

+ (nullable instancetype)instanceFromClientActionInjectedIoDataWithData:(nonnull ADJIoData *)clientActionInjectedIoData
                                                                 logger:(nonnull ADJLogger *)logger;

- (nullable instancetype)init NS_UNAVAILABLE;

// public properties
@property (nonnull, readonly, strong, nonatomic) ADJNonEmptyString *eventId;
@property (nullable, readonly, strong, nonatomic) ADJNonEmptyString *deduplicationId;
@property (nullable, readonly, strong, nonatomic) ADJMoney *revenue;
@property (nullable, readonly, strong, nonatomic) ADJStringMap *callbackParameters;
@property (nullable, readonly, strong, nonatomic) ADJStringMap *partnerParameters;

@end

