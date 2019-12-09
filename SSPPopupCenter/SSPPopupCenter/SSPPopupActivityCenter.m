//
//  SSPPopupActivityCenter.m
//  SSPPopupCenter
//
//  Created by HaiguangHuang on 2019/12/5.
//  Copyright © 2019 AirPay. All rights reserved.
//

#import "SSPPopupActivityCenter.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static char kSSPPopupShowStatus;

@interface SSPPopupActivityCenter ()

@property (nonatomic, strong) NSArray <id<SSPPopupProtocol>> *activityList;
@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, assign) SSPPopupActivityLevel *level;

@end

@implementation SSPPopupActivityCenter

#pragma mark - LifeCycle
+ (instancetype)sharedInstance {
    static SSPPopupActivityCenter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SSPPopupActivityCenter alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(wakeup)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addRunloopObserver];
        });
    }
    return self;
}

#pragma mark - Private
- (void)wakeup {
    //do nothing
}

- (void)addRunloopObserver {
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    CFRunLoopObserverContext context = {0, (__bridge void *)self, &CFRetain, &CFRelease, NULL};
    static CFRunLoopObserverRef defaultModeObserver;
    defaultModeObserver = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopBeforeWaiting, YES, 0, &callback, &context);
    CFRunLoopAddObserver(runloop, defaultModeObserver, kCFRunLoopCommonModes);
    CFRelease(defaultModeObserver);
}

void callback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    NSArray *activityList = [SSPPopupActivityCenter sharedInstance].activityList;
    if (activityList.count == 0) {
        [[SSPPopupActivityCenter sharedInstance].displayLink setPaused:YES];
        return;
    }
    
    id<SSPPopupProtocol> popup = [[SSPPopupActivityCenter sharedInstance].activityList firstObject];
    BOOL isShow = [objc_getAssociatedObject(popup, &kSSPPopupShowStatus) boolValue];
    if (isShow && 0) {
        if ([popup respondsToSelector:@selector(superview)]) {
            id superView = [popup performSelector:@selector(superview)];
            if (nil == superView) {
                [[SSPPopupActivityCenter sharedInstance] dequeue:popup completion:nil];
                return;
            }
        } else if ([popup respondsToSelector:@selector(parentViewController)]) {
            id parentViewController = [popup performSelector:@selector(parentViewController)];
            if (nil == parentViewController) {
                [[SSPPopupActivityCenter sharedInstance] dequeue:popup completion:nil];
                return;
            }
        }
        return;
    }
    
    if ([popup respondsToSelector:@selector(ssp_swizzle_show)]) {
        [popup performSelector:@selector(ssp_swizzle_show)];
        objc_setAssociatedObject(popup, &kSSPPopupShowStatus, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        [[SSPPopupActivityCenter sharedInstance].lock lock];
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[SSPPopupActivityCenter sharedInstance].activityList];
        [tempArray removeObjectAtIndex:0];
        [SSPPopupActivityCenter sharedInstance].activityList = tempArray;
        [[SSPPopupActivityCenter sharedInstance].lock unlock];
    }
}

#pragma mark - Public
- (void)enqueue:(id<SSPPopupProtocol>)activity completion:(SSPPopupActivityCompletion _Nullable)completion {
    if (nil == activity) {
        return;
    }
    
    [[SSPPopupActivityCenter sharedInstance].lock lock];
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[SSPPopupActivityCenter sharedInstance].activityList];
    if ([tempArray containsObject:activity]) {
        return;
    }
    
    if (tempArray.count > 1 &&
        [activity respondsToSelector:@selector(ssp_level)] &&
        SSPPopupActivityLevelHigh == [activity ssp_level]) {
        [tempArray insertObject:activity atIndex:1];
    } else {
        [tempArray addObject:activity];
    }
    [SSPPopupActivityCenter sharedInstance].activityList = tempArray;
    
    if ([SSPPopupActivityCenter sharedInstance].activityList.count > 0 &&
        [[SSPPopupActivityCenter sharedInstance].displayLink isPaused]) {
        [[SSPPopupActivityCenter sharedInstance].displayLink setPaused:NO];
    }
    
    [[SSPPopupActivityCenter sharedInstance].lock unlock];
    
    if (completion) {
        completion(activity);
    }
}

- (void)dequeue:(id<SSPPopupProtocol>)activity completion:(SSPPopupActivityCompletion _Nullable)completion {
    if (nil == activity) {
        return;
    }
    
    [[SSPPopupActivityCenter sharedInstance].lock lock];
    objc_setAssociatedObject(activity, &kSSPPopupShowStatus, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[SSPPopupActivityCenter sharedInstance].activityList];
    if (tempArray.count == 0) {
        return;
    }
    [tempArray removeObjectAtIndex:0];
    [SSPPopupActivityCenter sharedInstance].activityList = tempArray;
    if ([SSPPopupActivityCenter sharedInstance].activityList.count == 0) {
        [[SSPPopupActivityCenter sharedInstance].displayLink setPaused:YES];
    }
    [[SSPPopupActivityCenter sharedInstance].lock unlock];
    
    if (completion) {
        completion(activity);
    }
}
@end
