//
//  SimpleHttpApiManager.m
//  DDHTTPClientDemo
//
//  Created by TongAn001 on 2018/6/12.
//  Copyright © 2018年 abiang. All rights reserved.
//

#import "SimpleHttpApiManager.h"
#import "SimpleHTTPClient.h"

@implementation SimpleHttpApiManager

- (NSString *)apiVersin{
    return @"1.0";
}
- (NSString *)apiPrefix{
    return @"studentApp";
}

#pragma mark - Override
- (Class)clientClass{
    return SimpleHTTPClient.class;
}
- (NSString *)apiHost{
    return @"192.168.12.1";
}
- (NSString *)apiPort{
    return @"8080";
}
- (NSString *)apiPath{
    return @"login";
}
- (NSString *)apiURL{
    NSString * url = [NSString stringWithFormat:@"%@:%@/%@/%@/%@",self.apiHost,self.apiPort,self.apiPrefix,self.apiVersin,self.apiPath];
    return url;
}

- (void)responseReformer:(id)response{
    self.code = ((NSNumber *)response[@"t_code"]).integerValue;
    self.msg = response[@"t_msg"];
    self.data = response[@"t_data"];
}


@end
