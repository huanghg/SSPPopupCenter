//
//  SSPPopupActivityCenter.h
//  SSPPopupCenter
//
//  Created by HaiguangHuang on 2019/12/5.
//  Copyright © 2019 AirPay. All rights reserved.
//

#import "SSPPopupProtocol.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSPPopupActivityCenter : NSObject

+ (instancetype)sharedInstance;

- (void)enqueue:(id<SSPPopupProtocol>)activity completion:(SSPPopupActivityCompletion _Nullable)completion;

- (void)dequeue:(id<SSPPopupProtocol>)activity completion:(SSPPopupActivityCompletion _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
