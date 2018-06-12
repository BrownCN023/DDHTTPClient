//
//  DDHttpApiManager.h
//  DDToolboxExample
//
//  Created by brown on 2018/6/7.
//  Copyright © 2018年 ABiang. All rights reserved.
//  from casa:https://casatwy.com/iosying-yong-jia-gou-tan-wang-luo-ceng-she-ji-fang-an.html
//

#import <Foundation/Foundation.h>
#import "DDHTTPClient.h"

@class DDHttpApiManager;

@protocol DDHttpApiReformerProtocol <NSObject>
@required
- (NSDictionary *)reformDataWithManager:(DDHttpApiManager *)manager;
@end

@protocol DDHttpApiManagerDataSource <NSObject>
@required
- (NSString *)apiURL;
@optional
- (NSDictionary *)apiHeader;
- (NSDictionary *)apiParams;
@end

@protocol DDHttpApiManagerDelegate <NSObject>
@optional
- (void)apiManagerDidSuccess:(DDHttpApiManager *)manager;
- (void)apiManagerFailed:(DDHttpApiManager *)manager error:(NSError *)error;
@end

@interface DDHttpApiManager : NSObject

@property (nonatomic,assign) NSInteger code;
@property (nonatomic,copy) NSString * msg;
@property (nonatomic,strong) id data;

@property (nonatomic, weak, readonly) NSURLSessionDataTask * task;
@property (nonatomic,weak) id<DDHttpApiManagerDelegate> delegate;

- (Class)clientClass; //DDHTTPClient 或者其子类
- (NSDictionary *)fetchDataWithReformer:(id<DDHttpApiReformerProtocol>)reformer;
- (void)responseReformer:(id)response;
- (void)get;
- (void)post;
- (void)cancel;


@end
