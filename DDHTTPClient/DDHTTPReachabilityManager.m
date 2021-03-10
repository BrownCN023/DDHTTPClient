//
//  DDHTTPReachabilityManager.m
//  DDHTTPClientDemo
//
//  Created by abiaoyo on 2020/3/1.
//  Copyright © 2020 abiang. All rights reserved.
//

#import "DDHTTPReachabilityManager.h"
#import <AFNetworking/AFNetworking.h>

@interface DDHTTPReachabilityManager()
@property (nonatomic,weak) AFNetworkReachabilityManager * manager;
@property (nonatomic,strong) NSMapTable<id,id> * handlerContainer;
@end

@implementation DDHTTPReachabilityManager

+ (void)load{
    [DDHTTPReachabilityManager sharedManager];
}

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
    self.handlerContainer = [NSMapTable weakToStrongObjectsMapTable];
    self.manager = [AFNetworkReachabilityManager sharedManager];
    [_manager startMonitoring];
    [_manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
                case AFNetworkReachabilityStatusUnknown:{
                    #ifdef DEBUG
                    NSLog(@"🍄🍄🍄网络状态:未知");
                    #endif
                }
                break;
                case AFNetworkReachabilityStatusNotReachable:{
                    #ifdef DEBUG
                    NSLog(@"🍄🍄🍄网络状态:不可用");
                    #endif
                }
                break;
                case AFNetworkReachabilityStatusReachableViaWWAN:{
                    #ifdef DEBUG
                    NSLog(@"🍄🍄🍄网络状态:2G/3G/4G/5G");
                    #endif
                }
                break;
                case AFNetworkReachabilityStatusReachableViaWiFi:{
                    #ifdef DEBUG
                    NSLog(@"🍄🍄🍄网络状态:WIFI");
                    #endif
                }
                break;
                
            default:{
                #ifdef DEBUG
                NSLog(@"🍄🍄🍄网络状态:Other");
                #endif
            }
                break;
        }
        NSEnumerator * enumerator = self.handlerContainer.objectEnumerator;
        id obj = nil;
        while (obj = [enumerator nextObject]) {
            DDHTTPNetworkStatusHandler handler = obj;
            handler((DDHTTPNetworkStatus)status);
        }
    }];
    
}

- (DDHTTPNetworkStatus)status{
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

- (void)addListener:(id)listener handler:(DDHTTPNetworkStatusHandler)handler{
    if(listener){
        [self.handlerContainer setObject:handler forKey:listener];
    }
}
- (void)removeListener:(id)listener{
    if(listener){
        [self.handlerContainer removeObjectForKey:listener];
    }
}
- (void)removeAllListener{
    [self.handlerContainer removeAllObjects];
}


@end
