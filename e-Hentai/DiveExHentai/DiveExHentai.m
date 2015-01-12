//
//  DiveExHentai.m
//  e-Hentai
//
//  Created by 啟倫 陳 on 2014/12/15.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "DiveExHentai.h"

#import <objc/runtime.h>

typedef enum {
    DiveExHentaiStatusFirstCheck,
    DiveExHentaiStatusFinish
} DiveExHentaiStatus;

@implementation DiveExHentai

#pragma mark - class method

+ (void)diveWhenCompletion:(void (^)(BOOL isSuccess))completion {
    [self setCompletion:completion];
    [self setStatus:DiveExHentaiStatusFirstCheck];
    [[self hentaiWebView] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://exhentai.org/"]]];
}

#pragma mark - UIWebViewDelegate

+ (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *htmlTitle = [[self hentaiWebView] stringByEvaluatingJavaScriptFromString:@"document.title"];
    switch ([self status]) {
        case DiveExHentaiStatusFirstCheck:
        {
            if ([htmlTitle isEqualToString:@"ExHentai.org"]) {
                [self completion](YES);
                objc_removeAssociatedObjects(self);
            }
            else {
                [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://s3-ap-northeast-1.amazonaws.com/daidoujiminecraft/Daidouji/ehentai/cookies.json"]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    
                    if (connectionError) {
                        [self completion](NO);
                    }
                    else {
                        NSArray *responseResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                        
                        NSMutableArray *cookies = [NSMutableArray array];
                        
                        for (NSDictionary *eachCookie in responseResult) {
                            NSMutableDictionary *newProperties = [NSMutableDictionary dictionary];
                            newProperties[@"Domain"] = [eachCookie[@"domain"] stringByReplacingOccurrencesOfString:@"e-hentai" withString:@"exhentai"];
                            newProperties[@"Expires"] = [NSDate dateWithTimeIntervalSince1970:[eachCookie[@"expirationDate"] floatValue]];
                            newProperties[@"Name"] = eachCookie[@"name"];
                            newProperties[@"Path"] = eachCookie[@"path"];
                            newProperties[@"Value"] = eachCookie[@"value"];
                            NSHTTPCookie *newCookie = [[NSHTTPCookie alloc] initWithProperties:newProperties];
                            [cookies addObject:newCookie];
                        }
                        
                        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                        for (NSHTTPCookie *each in cookieStorage.cookies) {
                            [cookieStorage deleteCookie:each];
                        }
                        
                        for (NSHTTPCookie *eachCookies in cookies) {
                            [cookieStorage setCookie:eachCookies];
                        }
                        
                        [self setStatus:DiveExHentaiStatusFinish];
                        [[self hentaiWebView] reload];
                    }
                }];
            }
            break;
        }
        
        //成功的話就可以潛入 exhentai 了
        case DiveExHentaiStatusFinish:
        {
            if ([htmlTitle isEqualToString:@"ExHentai.org"]) {
                [self completion](YES);
            }
            else {
                [self completion](NO);
            }
            objc_removeAssociatedObjects(self);
            break;
        }
    }
}

#pragma mark - runtime objects

+ (UIWebView *)hentaiWebView {
    if (!objc_getAssociatedObject(self, _cmd)) {
        UIWebView *hentaiWebView = [UIWebView new];
        hentaiWebView.delegate = (id <UIWebViewDelegate> )self;
        objc_setAssociatedObject(self, _cmd, hentaiWebView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, _cmd);
}

+ (void)setCompletion:(void (^)(BOOL isSuccess))completion {
    objc_setAssociatedObject(self, @selector(completion), completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (void (^)(BOOL successed))completion {
    return objc_getAssociatedObject(self, _cmd);
}

+ (void)setStatus:(int)status {
    objc_setAssociatedObject(self, @selector(status), @(status), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (int)status {
    NSNumber *status = objc_getAssociatedObject(self, _cmd);
    return status.intValue;
}

@end
