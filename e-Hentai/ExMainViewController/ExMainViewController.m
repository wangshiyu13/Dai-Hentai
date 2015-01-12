//
//  ExMainViewController.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/12/16.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "ExMainViewController.h"

#import "DiveExHentai.h"

@interface ExMainViewController ()

@property (nonatomic, assign) BOOL onceFlag;

@end

@implementation ExMainViewController

#pragma mark - dynamic

- (NSString *)filterString {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    NSString *filterString = [self performSelector:@selector(filterDependOnURL:) withObject:@"http://exhentai.org//?page=%lu"];
#pragma clang diagnostic pop
    return filterString;
}

#pragma mark - life cycle

- (void)viewWillAppear:(BOOL)animated {
    self.onceFlag = NO;
    [super viewWillAppear:animated];
    [SVProgressHUD show];
    [DiveExHentai diveWhenCompletion: ^(BOOL isSuccess) {
        if (isSuccess) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            [self performSelector:@selector(reloadDatas)];
#pragma clang diagnostic pop
        }
        else {
            [UIAlertView hentai_alertViewWithTitle:@"也許哪邊出錯囉~ >3<" message:@"Sorry, 晚點再試吧." cancelButtonTitle:@"好~ O3O"];
        }
        [SVProgressHUD dismiss];
    }];
}

@end
