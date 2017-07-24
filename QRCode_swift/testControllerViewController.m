//
//  testControllerViewController.m
//  QRCode_swift
//
//  Created by Hongpeng Yu on 2017/7/20.
//  Copyright © 2017年 Hongpeng Yu. All rights reserved.
//

#import "testControllerViewController.h"
#import "QRCode_swift-Swift.h"



@interface testControllerViewController ()<WZQRCodeControllerDelegate>

@end

@implementation testControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WZQRCodeController *qrVc = [[WZQRCodeController alloc] init];
    qrVc.delegate = self;
    
    // Do any additional setup after loading the view.
}


/**
 代理方法
 */
- (void)qrController:(WZQRCodeController *)QRcodeControlle scanFinishWithInfo:(NSArray<NSString *> *)info {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
