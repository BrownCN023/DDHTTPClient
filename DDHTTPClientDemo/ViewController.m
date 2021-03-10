//
//  ViewController.m
//  DDHTTPClientDemo
//
//  Created by TongAn001 on 2018/5/31.
//  Copyright © 2018年 abiang. All rights reserved.
//

#import "ViewController.h"
#import "DDHTTPClient.h"
#import "DDHTTPReachabilityManager.h"

@interface ViewController ()

@property (nonatomic,strong) DDHTTPTaskBox * taskBox;

@end

@implementation ViewController

- (void)dealloc{
    [self.taskBox removeAllTask];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.taskBox = [DDHTTPTaskBox createTaskBox];
    NSLog(@"DDHTTPReachabilityManager.sharedManager.networkStatus:%@",@(DDHTTPReachabilityManager.sharedManager.status));
    
    DDHTTPRequest * request = DDHTTPClient
    .createRequest
    .notes(@"dcloud-api")
    .method(DDHTTPMethodGet)
    .url(@"https://unidemo.dcloud.net.cn/api/news")
    .header(nil)
    .params(nil)
    .progress(^(NSProgress *downloadProgress) {
        NSLog(@"downloadProgress:%@",downloadProgress);
    }).success(^(NSURLSessionDataTask *task, id response) {
        NSLog(@"response:%@",response);
    }).failure(^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@",error);
    });
    
    [self.taskBox addTask:[DDHTTPClient sendRequest:request]];
    
}

@end
