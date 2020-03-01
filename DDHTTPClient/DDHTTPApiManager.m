//
//  DDHTTPApiManager.m
//  DDToolboxExample
//
//  Created by brown on 2018/6/7.
//  Copyright © 2018年 ABiang. All rights reserved.
//

#import "DDHTTPApiManager.h"

@interface DDHTTPApiManager()

@property (nonatomic, weak) id<DDHTTPApiManagerDataSource> child;
@property (nonatomic, weak) NSURLSessionDataTask * task;

@end

@implementation DDHTTPApiManager

- (void)dealloc{
    [self cancel];
}

- (instancetype)init{
    self = [super init];
    if ([self conformsToProtocol:@protocol(DDHTTPApiManagerDataSource)]) {
        self.child = (id<DDHTTPApiManagerDataSource>)self;
    } else {
        NSAssert(NO, @"子类必须要实现APIManager这个protocol。");
    }
    return self;
}

- (NSDictionary *)apiHeader{
    return nil;
}

- (NSDictionary *)apiParams{
    return nil;
}

- (NSString *)apiURL{
    return nil;
}


- (NSDictionary *)fetchDataWithReformer:(id<DDHttpApiReformerProtocol>)reformer{
    if (reformer == nil) {
        return @{
                 @"code":@(self.code),
                 @"msg":self.msg,
                 @"data":self.data
                 };
    } else {
        return [reformer reformDataWithManager:self];
    }
}

- (void)responseReformer:(id)response{
    self.code = ((NSNumber *)response[@"code"]).integerValue;
    self.msg = response[@"msg"];
    self.data = response[@"data"];
}

- (DDHTTPRequest *)createRequest{
    __weak typeof(self) weakself = self;
    return DDHTTPClient
    .createRequest
    .url(self.child.apiURL)
    .header(self.child.apiHeader)
    .params(self.child.apiParams)
    .success(^(NSURLSessionDataTask *task, id response){
        [weakself responseReformer:response];
        if(weakself.delegate && [weakself.delegate respondsToSelector:@selector(apiManagerDidSuccess:)]){
            [weakself.delegate apiManagerDidSuccess:weakself];
        }
    }).failure(^(NSURLSessionDataTask *task, NSError *error){
        if(weakself.delegate && [weakself.delegate respondsToSelector:@selector(apiManagerFailed:error:)]){
            [weakself.delegate apiManagerFailed:weakself error:error];
        }
    });
}

- (void)get{
    self.task = [DDHTTPClient sendRequest:[self createRequest].method(DDHTTP_Method_Get)];
}

- (void)post{
    self.task = [DDHTTPClient sendRequest:[self createRequest].method(DDHTTP_Method_Post)];
}

- (void)cancel{
    if(self.task){
        [self.task cancel];
    }
}

@end
