//
//  ViewController.m
//  SSPPopupCenterDemo
//
//  Created by HaiguangHuang on 2019/12/5.
//  Copyright © 2019 AirPay. All rights reserved.
//

#import "ViewController.h"
#import "SSPPopupView.h"
#import <SSPPopupCenter/SSPPopupCenter.h>

@interface ViewController ()

@property (nonatomic, strong) SSPPopupView *popupView1;
@property (nonatomic, strong) SSPPopupView *popupView2;
@property (nonatomic, strong) SSPPopupView *popupView3;
@property (nonatomic, strong) SSPPopupView *popupView4;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (SSPPopupView *)popupView1 {
    if (!_popupView1) {
        _popupView1 = [[SSPPopupView alloc] initWithFrame:CGRectMake(10, 0, 40, 100)];
        _popupView1.backgroundColor = [UIColor redColor];
    }
    return _popupView1;
}

- (SSPPopupView *)popupView2 {
    if (!_popupView2) {
        _popupView2 = [[SSPPopupView alloc] initWithFrame:CGRectMake(50, 100, 40, 100)];
        _popupView2.backgroundColor = [UIColor orangeColor];
    }
    return _popupView2;
}

- (SSPPopupView *)popupView3 {
    if (!_popupView3) {
        _popupView3 = [[SSPPopupView alloc] initWithFrame:CGRectMake(100, 200, 40, 100)];
        _popupView3.backgroundColor = [UIColor yellowColor];
    }
    return _popupView3;
}

- (SSPPopupView *)popupView4 {
    if (!_popupView4) {
        _popupView4 = [[SSPPopupView alloc] initWithFrame:CGRectMake(150, 300, 40, 100)];
        _popupView4.backgroundColor = [UIColor greenColor];
    }
    return _popupView4;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.popupView1 ssp_show];
    [self.popupView2 ssp_show];
    [self.popupView3 ssp_show];
    self.popupView4.ssp_level = SSPPopupActivityLevelHigh;
    [self.popupView4 ssp_show];
}

@end
