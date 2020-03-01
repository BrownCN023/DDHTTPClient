//
//  SimpleHttpApiManager.h
//  DDHTTPClientDemo
//
//  Created by TongAn001 on 2018/6/12.
//  Copyright © 2018年 abiang. All rights reserved.
//

#import "DDHTTPApiManager.h"

@class SimpleHttpApiManager;
@protocol SimpleHttpApiReformerProtocol <DDHttpApiReformerProtocol>
@required
- (NSDictionary *)reformDataWithManager:(SimpleHttpApiManager *)manager;
@end

@interface SimpleHttpApiManager : DDHTTPApiManager<DDHTTPApiManagerDataSource>

- (NSString *)apiHost;
- (NSString *)apiPort;
- (NSString *)apiPath;
- (NSString *)apiVersin;
- (NSString *)apiPrefix;

@end
