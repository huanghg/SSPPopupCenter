//
//  SSPPopupView.m
//  SSPPopupCenterDemo
//
//  Created by HaiguangHuang on 2019/12/5.
//  Copyright © 2019 AirPay. All rights reserved.
//

#import "SSPPopupView.h"
#import <SSPPopupCenter/SSPPopupCenter.h>

@implementation SSPPopupView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        [self ssp_registerToPopupCenter];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self ssp_hide];
}

- (void)ssp_show {
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
}

- (void)ssp_hide {
    [self removeFromSuperview];
}

@end
