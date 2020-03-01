//
//  DDHTTPReachabilityManager.m
//  DDHTTPClientDemo
//
//  Created by abiaoyo on 2020/3/1.
//  Copyright © 2020 abiang. All rights reserved.
//

#import "DDHTTPReachabilityManager.h"
#import "AFNetworking.h"

@interface DDHTTPReachabilityManager(){
    NSHashTable * _delegates;
}
@property (nonatomic,assign) DDHTTPNetworkStatus networkStatus;
@property (nonatomic,weak) AFNetworkReachabilityManager * manager;

@end

@implementation DDHTTPReachabilityManager

+ (DDHTTPReachabilityManager *)sharedManager{
    static DDHTTPReachabilityManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [DDHTTPReachabilityManager new];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupInit];
    }
    return self;
}

- (void)setupInit{
    _delegates = [NSHashTable weakObjectsHashTable];
    __weak typeof(self) weakself = self;
    
    self.manager = [AFNetworkReachabilityManager sharedManager];
    [_manager startMonitoring];
    [_manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
                case AFNetworkReachabilityStatusUnknown:{
                    NSLog(@"🍄🍄🍄网络状态:未知");
                }
                break;
                case AFNetworkReachabilityStatusNotReachable:{
                    NSLog(@"🍄🍄🍄网络状态:不可用");
                }
                break;
                case AFNetworkReachabilityStatusReachableViaWWAN:{
                    NSLog(@"🍄🍄🍄网络状态:2G/3G/4G/5G");
                }
                break;
                case AFNetworkReachabilityStatusReachableViaWiFi:{
                    NSLog(@"🍄🍄🍄网络状态:WIFI");
                }
                break;
                
            default:{
                NSLog(@"🍄🍄🍄网络状态:Other");
            }
                break;
        }
        NSArray * allDelegate = _delegates.allObjects;
        [allDelegate enumerateObjectsUsingBlock:^(id  _Nonnull delegate, NSUInteger idx, BOOL * _Nonnull stop) {
            if(delegate && [delegate respondsToSelector:@selector(ddNetworkManager:reachabilityStatus:)]){
                [delegate ddNetworkManager:weakself reachabilityStatus:weakself.networkStatus];
            }
        }];
    }];
    
}

- (DDHTTPNetworkStatus)networkStatus{
    return (DDHTTPNetworkStatus)_manager.networkReachabilityStatus;
}
- (BOOL)isReachable{
    return _manager.isReachable;
}
- (BOOL)isReachableViaWWAN{
    return _manager.isReachableViaWWAN;
}
- (BOOL)isReachableViaWiFi{
    return _manager.isReachableViaWiFi;
}
- (void)addDelegate:(id<DDHTTPReachabilityManagerDelegate>)delegate{
    [_delegates addObject:delegate];
}
- (void)removeDelegate:(id<DDHTTPReachabilityManagerDelegate>)delegate{
    [_delegates removeObject:delegate];
}
- (void)removeAllDelegate{
    [_delegates removeAllObjects];
}

@end
