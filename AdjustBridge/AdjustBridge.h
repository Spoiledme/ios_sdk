//
//  AdjustBridge.h
//  Adjust
//
//  Created by Aditi Agrawal on 14/05/24.
//  Copyright © 2024 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface AdjustBridge : NSObject

- (void)loadWKWebViewBridge:(WKWebView *_Nonnull)wkWebView;
- (void)augmentHybridWebView;

@property (strong, nonatomic) WKWebView * _Nonnull wkWebView;

@end
