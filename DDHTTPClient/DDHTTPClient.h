//
//  DDHTTPClient.h
//  DDToolboxExample
//
//  Created by brown on 2018/5/10.
//  Copyright © 2018年 ABiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef NS_ENUM(NSInteger,DDHTTPUploadComponentType) {
    DDHTTPUploadComponentTypeData = 0,
    DDHTTPUploadComponentTypeFilePath = 1
};

@interface DDHTTPUploadComponent : NSObject
@property (nonatomic,assign) DDHTTPUploadComponentType fileType;
@property (nonatomic,strong) NSData * data;
@property (nonatomic,copy) NSString * name;
@property (nonatomic,copy) NSString * fileName;
@property (nonatomic,copy) NSString * filePath;
@property (nonatomic,copy) NSString * mimeType;

- (instancetype)initWithFileType:(DDHTTPUploadComponentType)fileType
                            name:(NSString *)name
                            data:(NSData *)data
                        filename:(NSString *)filename;

- (instancetype)initWithFileType:(DDHTTPUploadComponentType)fileType
                            name:(NSString *)name
                        filePath:(NSString *)filePath
                        filename:(NSString *)filename
                        mimeType:(NSString *)mimeType;

@end

typedef NS_ENUM(NSInteger,DDHTTP_Method) {
    DDHTTP_Method_Get = 0,
    DDHTTP_Method_Post,
    DDHTTP_Method_Head,
    DDHTTP_Method_Put,
    DDHTTP_Method_Patch,
    DDHTTP_Method_Delete
};

typedef void (^DDHTTPProgressBlock)(NSProgress *downloadProgress);
typedef void (^DDHTTPSuccessBlock)(NSURLSessionDataTask *task, id response);
typedef void (^DDHTTPFailureBlock)(NSURLSessionDataTask *task, NSError *error);
typedef NSURL * (^DDHTTPDownloadDestinationBlock)(NSURL * targetPath, NSURLResponse * response);
typedef void (^DDHTTPDownloadCompletionBlock)(NSURLResponse * response, NSURL * filePath, NSError * error);
typedef void (^DDHTTPManagerConfigBlock)(AFHTTPSessionManager * manager);


@class DDHTTPRequest;
typedef DDHTTPRequest *(^DDHTTPRequestDownloadDestination)(DDHTTPDownloadDestinationBlock callBlock);
typedef DDHTTPRequest *(^DDHTTPRequestDownloadCompletion)(DDHTTPDownloadCompletionBlock callBlock);
typedef DDHTTPRequest *(^DDHTTPRequestProgress)(DDHTTPProgressBlock callBlock);
typedef DDHTTPRequest *(^DDHTTPRequestSuccess)(DDHTTPSuccessBlock callBlock);
typedef DDHTTPRequest *(^DDHTTPRequestFailure)(DDHTTPFailureBlock callBlock);


@interface DDHTTPRequest : NSObject

@property (nonatomic,strong,readonly) DDHTTPRequest * (^url)(NSString * url);
@property (nonatomic,strong,readonly) DDHTTPRequest * (^header)(NSDictionary * header);
@property (nonatomic,strong,readonly) DDHTTPRequest * (^params)(NSDictionary * params);
@property (nonatomic,strong,readonly) DDHTTPRequest * (^uploadFiles)(NSArray<DDHTTPUploadComponent *> * files);
@property (nonatomic,strong,readonly) DDHTTPRequestDownloadDestination downloadDestination;
@property (nonatomic,strong,readonly) DDHTTPRequestDownloadCompletion downloadCompletion;
@property (nonatomic,strong,readonly) DDHTTPRequestProgress progress;
@property (nonatomic,strong,readonly) DDHTTPRequestSuccess success;
@property (nonatomic,strong,readonly) DDHTTPRequestFailure failure;
@property (nonatomic,strong,readonly) DDHTTPRequest * (^managerConfig)(void (^)(AFHTTPSessionManager * manager));
@property (nonatomic,strong,readonly) DDHTTPRequest * (^method)(DDHTTP_Method m);

@end

@interface DDHTTPClient : NSObject

+ (DDHTTPRequest *)createRequest;
+ (NSURLSessionDataTask *)sendRequest:(DDHTTPRequest *)req;
+ (NSURLSessionDataTask *)sendUploadRequest:(DDHTTPRequest *)req;
+ (NSURLSessionDownloadTask *)sendDownloadRequest:(DDHTTPRequest *)req;

@end

@interface DDHTTPTaskBox : NSObject

+ (DDHTTPTaskBox *)createTaskBox;

- (void)addTask:(NSURLSessionTask *)task;
- (void)removeTask:(NSURLSessionTask *)task;
- (void)removeAllTask;

@end

/**
 e.g.
 
 DDHTTPRequest * request = DDHTTPClient
 .createRequest
 .method(DDHTTP_Method_Get)
 .url(@"https://unidemo.dcloud.net.cn/api/news")
 .header(nil)
 .params(nil)
 .progress(^(NSProgress *downloadProgress) {
    NSLog(@"downloadProgress:%@",downloadProgress);
 }).success(^(NSURLSessionDataTask *task, id response) {
    NSLog(@"response:%@",response);
 }).failure(^(NSURLSessionDataTask *task, NSError *error) {
    NSLog(@"error:%@",error);
 });
 
 [DDHTTPClient sendRequest:request];

 */
