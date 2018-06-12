//
//  DDHttpApiManager.m
//  DDToolboxExample
//
//  Created by brown on 2018/6/7.
//  Copyright © 2018年 ABiang. All rights reserved.
//

#import "DDHttpApiManager.h"

@interface DDHttpApiManager()

@property (nonatomic, weak) id<DDHttpApiManagerDataSource> child;
@property (nonatomic, weak) NSURLSessionDataTask * task;

@end

@implementation DDHttpApiManager

- (void)dealloc{
    [self.task cancel];
}

- (instancetype)init{
    self = [super init];
    if ([self conformsToProtocol:@protocol(DDHttpApiManagerDataSource)]) {
        self.child = (id<DDHttpApiManagerDataSource>)self;
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

- (Class)clientClass{
    return DDHTTPClient.class;
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

- (DDHTTPClient *)createHTTPClient{
    __weak typeof(self) weakself = self;
    return [[self clientClass] createClient]
    .url(self.child.apiURL)
    .header(self.child.apiHeader)
    .params(self.child.apiParams)
    .success(^(id response){
        [weakself responseReformer:response];
        if(weakself.delegate && [weakself.delegate respondsToSelector:@selector(apiManagerDidSuccess:)]){
            [weakself.delegate apiManagerDidSuccess:weakself];
        }
    }).failure(^(NSError * error){
        if(weakself.delegate && [weakself.delegate respondsToSelector:@selector(apiManagerFailed:error:)]){
            [weakself.delegate apiManagerFailed:weakself error:error];
        }
    });
}

- (void)get{
    self.task = [[self createHTTPClient] get];
}

- (void)post{
    self.task = [[self createHTTPClient] post];
}

- (void)cancel{
    if(self.task){
        [self.task cancel];
    }
}

@end
