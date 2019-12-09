//
//  NSObject+SSPPopupCenter.m
//  SSPPopupCenter
//
//  Created by HaiguangHuang on 2019/12/7.
//  Copyright © 2019 AirPay. All rights reserved.
//

#import "NSObject+SSPPopupCenter.h"
#import "SSPPopupActivityCenter.h"
#import <objc/runtime.h>

static char kSSPopupCenterLevel;

@implementation NSObject (SSPPopupCenter)

- (void)ssp_registerToPopupCenter {
    BOOL flag = [self conformsToProtocol:@protocol(SSPPopupProtocol)];
    NSString *msg = [NSString stringWithFormat:@"%@ should conform SSPPopupProtocol", NSStringFromClass([self class])];
    NSAssert(flag, msg);
    
    NSString * className = [NSString stringWithFormat:@"SSPPopupCenter_%@",NSStringFromClass(self.class)];
    const char *cla = className.UTF8String;
    Class subP = objc_allocateClassPair([self class], cla, 0);
    
    if (nil != subP && ![subP isKindOfClass:[self class]]) {
        [self swizzleClass:subP method:@selector(ssp_show) swizzledSelector:@selector(ssp_swizzle_show)];
        
        if (nil != class_getInstanceMethod([self class], @selector(ssp_hide))) {
            [self swizzleClass:subP method:@selector(ssp_hide) swizzledSelector:@selector(ssp_swizzle_hide)];
        }
        
        [self addClass:[self class] method:@selector(ssp_level)];
        [self addClass:[self class] method:@selector(setSsp_level:)];
        
        objc_registerClassPair(subP);
    } else {
        subP = objc_getClass(cla);
    }
    object_setClass(self, subP);
}

- (void)swizzleClass:(Class)clazz method:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    Method originalMethod = class_getInstanceMethod(clazz, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(clazz, swizzledSelector);
    
    if (originalMethod && swizzledMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
        return;
    }
    
    if (nil == swizzledMethod) {
        BOOL didAddMethod = class_addMethod(clazz,
                                            swizzledSelector,
                                            method_getImplementation(originalMethod),
                                            method_getTypeEncoding(originalMethod));
        if (didAddMethod) {
            swizzledMethod = class_getInstanceMethod(clazz, swizzledSelector);
        }
    }

    if (swizzledMethod) {
        class_replaceMethod(clazz,
                            originalSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
    }
}

- (void)addClass:(Class)clazz method:(SEL)selector {
    Method method = class_getInstanceMethod(clazz, selector);
    BOOL didAddMethod = class_addMethod(clazz,
                                        selector,
                                        method_getImplementation(method),
                                        method_getTypeEncoding(method));
    NSAssert(didAddMethod, @"add method failure");
}

- (void)ssp_swizzle_show {
    [[SSPPopupActivityCenter sharedInstance] enqueue:(id<SSPPopupProtocol>)self completion:nil];
}

- (void)ssp_swizzle_hide {
    [[SSPPopupActivityCenter sharedInstance] dequeue:(id<SSPPopupProtocol>)self completion:nil];
    [self ssp_swizzle_hide];
}

- (SSPPopupActivityLevel)ssp_level {
    return [objc_getAssociatedObject(self, &kSSPopupCenterLevel) integerValue];
}

- (void)setSsp_level:(SSPPopupActivityLevel)level {
    objc_setAssociatedObject(self, &kSSPopupCenterLevel, @(level), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
