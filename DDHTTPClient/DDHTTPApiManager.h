//
//  DDHTTPApiManager.h
//  DDToolboxExample
//
//  Created by brown on 2018/6/7.
//  Copyright © 2018年 ABiang. All rights reserved.
//  from casa:https://casatwy.com/iosying-yong-jia-gou-tan-wang-luo-ceng-she-ji-fang-an.html
//

#import <Foundation/Foundation.h>
#import "DDHTTPClient.h"

@class DDHTTPApiManager;

@protocol DDHttpApiReformerProtocol <NSObject>
@required
- (NSDictionary *)reformDataWithManager:(DDHTTPApiManager *)manager;
@end

@protocol DDHTTPApiManagerDataSource <NSObject>
@required
- (NSString *)apiURL;
@optional
- (NSDictionary *)apiHeader;
- (NSDictionary *)apiParams;
@end

@protocol DDHTTPApiManagerDelegate <NSObject>
@optional
- (void)apiManagerDidSuccess:(DDHTTPApiManager *)manager;
- (void)apiManagerFailed:(DDHTTPApiManager *)manager error:(NSError *)error;
@end

@interface DDHTTPApiManager : NSObject

@property (nonatomic,assign) NSInteger code;
@property (nonatomic,copy) NSString * msg;
@property (nonatomic,strong) id data;

@property (nonatomic, weak, readonly) NSURLSessionDataTask * task;
@property (nonatomic,weak) id<DDHTTPApiManagerDelegate> delegate;

- (NSDictionary *)fetchDataWithReformer:(id<DDHttpApiReformerProtocol>)reformer;
- (void)responseReformer:(id)response;
- (void)get;
- (void)post;
- (void)cancel;


@end
