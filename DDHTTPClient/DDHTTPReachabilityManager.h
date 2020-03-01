//
//  DDHTTPReachabilityManager.h
//  DDHTTPClientDemo
//
//  Created by abiaoyo on 2020/3/1.
//  Copyright © 2020 abiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DDHTTPNetworkStatus) {
    DDHTTPNetworkStatusUnknown          = -1, //未知
    DDHTTPNetworkStatusNotReachable     = 0,  //无网络
    DDHTTPNetworkStatusReachableViaWWAN = 1,  //蜂窝网络
    DDHTTPNetworkStatusReachableViaWiFi = 2,  //WiFi
};

@class DDHTTPReachabilityManager;
@protocol DDHTTPReachabilityManagerDelegate <NSObject>
@optional
- (void)ddNetworkManager:(DDHTTPReachabilityManager *)manager reachabilityStatus:(DDHTTPNetworkStatus)status;
@end

@interface DDHTTPReachabilityManager : NSObject

@property (readonly, nonatomic,assign) DDHTTPNetworkStatus networkStatus;  //当前网络的状态
@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable; //当前网络是否可用（蜂窝网或WiFi）
@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN; //当前网络是否是蜂窝网
@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi; //当前网络是否是WiFi

+ (DDHTTPReachabilityManager *)sharedManager;
- (void)addDelegate:(id<DDHTTPReachabilityManagerDelegate>)delegate;
- (void)removeDelegate:(id<DDHTTPReachabilityManagerDelegate>)delegate;
- (void)removeAllDelegate;

@end

NS_ASSUME_NONNULL_END
