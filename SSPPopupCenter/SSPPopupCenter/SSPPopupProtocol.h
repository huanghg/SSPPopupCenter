//
//  SSPPopupProtocol.h
//  SSPPopupCenter
//
//  Created by HaiguangHuang on 2019/12/5.
//  Copyright © 2019 AirPay. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    SSPPopupActivityLevelNormal,
    SSPPopupActivityLevelHigh,
} SSPPopupActivityLevel;

@protocol SSPPopupProtocol <NSObject>

typedef void(^SSPPopupActivityCompletion)(id<SSPPopupProtocol> activity);

//暂时只有两种级别，normal：按顺序入栈。 high：会插到栈顶 默认：normal
@property (nonatomic, assign) SSPPopupActivityLevel ssp_level;

@required
- (void)ssp_show;

@optional
//可选，底层会监听superView或者parentViewController是否为nil
//如果这两个属性不足以支撑实现消失，使用者可以重写该方法
- (void)ssp_hide;

@end

NS_ASSUME_NONNULL_END
