//
//  SimpleHTTPClient.m
//  DDHTTPClientDemo
//
//  Created by TongAn001 on 2018/6/12.
//  Copyright © 2018年 abiang. All rights reserved.
//

#import "SimpleHTTPClient.h"

@implementation SimpleHTTPClient

+ (void)configSerializer:(AFHTTPSessionManager *)manager{
    //    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"text/html",
                                                         @"text/xml",
                                                         @"text/plain",
                                                         @"application/json",
                                                         nil];
    manager.operationQueue.maxConcurrentOperationCount = 5;
    manager.requestSerializer.timeoutInterval = 30;
}

@end
