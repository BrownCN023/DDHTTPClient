//
//  DDHTTPClient.h
//  DDToolboxExample
//  
//  Created by brown on 2018/5/10.
//  Copyright © 2018年 ABiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef NS_ENUM(NSInteger,DDHTTPUploadFileType) {
    DDHTTPUploadFileTypeData = 0,
    DDHTTPUploadFileTypeFilePath = 1
};

@interface DDHTTPUploadModel : NSObject

@property (nonatomic,assign) DDHTTPUploadFileType fileType;
@property (nonatomic,strong) NSData * data;
@property (nonatomic,copy) NSString * name;
@property (nonatomic,copy) NSString * fileName;
@property (nonatomic,copy) NSString * filePath;
@property (nonatomic,copy) NSString * mimeType;

- (instancetype)initWithFileType:(DDHTTPUploadFileType)fileType name:(NSString *)name data:(NSData *)data filename:(NSString *)filename;
- (instancetype)initWithFileType:(DDHTTPUploadFileType)fileType name:(NSString *)name filePath:(NSString *)filePath filename:(NSString *)filename mimeType:(NSString *)mimeType;

@end

typedef NS_ENUM(NSInteger,DDHTTPMethod) {
    DDHTTPMethodGet = 0,
    DDHTTPMethodPost,
    DDHTTPMethodHead
};

typedef void (^DDHTTPProgressCallback)(NSProgress * progress);
typedef void (^DDHTTPSuccessCallback)(id response);
typedef void (^DDHTTPFailureCallback)(NSError * error);
typedef NSURL * (^DDHTTPDownloadDestination)(NSURL * targetPath, NSURLResponse * response);
typedef void (^DDHTTPDownloadCompletion)(NSURLResponse * response, NSURL * filePath, NSError * error);

@class DDHTTPRequest;
typedef DDHTTPRequest *(^DDHTTPRequestURL)(NSString * url);
typedef DDHTTPRequest *(^DDHTTPRequestHeader)(NSDictionary * header);
typedef DDHTTPRequest *(^DDHTTPRequestParams)(NSDictionary * params);
typedef DDHTTPRequest *(^DDHTTPRequestUploadFile)(NSArray<DDHTTPUploadModel *> * files);
typedef DDHTTPRequest *(^DDHTTPRequestDownloadDestination)(DDHTTPDownloadDestination callback);
typedef DDHTTPRequest *(^DDHTTPRequestDownloadCompletion)(DDHTTPDownloadCompletion callback);
typedef DDHTTPRequest *(^DDHTTPRequestProgress)(DDHTTPProgressCallback callback);
typedef DDHTTPRequest *(^DDHTTPRequestSuccess)(DDHTTPSuccessCallback callback);
typedef DDHTTPRequest *(^DDHTTPRequestFailure)(DDHTTPFailureCallback callback);


@interface DDHTTPRequest : NSObject

@property (nonatomic,strong,readonly) DDHTTPRequestURL url;
@property (nonatomic,strong,readonly) DDHTTPRequestHeader header;
@property (nonatomic,strong,readonly) DDHTTPRequestParams params;
@property (nonatomic,strong,readonly) DDHTTPRequestUploadFile uploadFiles;
@property (nonatomic,strong,readonly) DDHTTPRequestDownloadDestination downloadDestination;
@property (nonatomic,strong,readonly) DDHTTPRequestDownloadCompletion downloadCompletion;
@property (nonatomic,strong,readonly) DDHTTPRequestProgress progress;
@property (nonatomic,strong,readonly) DDHTTPRequestSuccess success;
@property (nonatomic,strong,readonly) DDHTTPRequestFailure failure;

+ (AFHTTPSessionManager *)httpManager;
+ (void)configSerializer:(AFHTTPSessionManager *)manager;

- (NSURLSessionDataTask *)head;
- (NSURLSessionDataTask *)get;
- (NSURLSessionDataTask *)post;
- (NSURLSessionDataTask *)upload;
- (NSURLSessionDownloadTask *)download;

@end

@interface DDHTTPClient : NSObject

+ (DDHTTPRequest *)createRequest;

@end

/**
    eg:
    [DDHTTPClient.createRequest.url(@"http://120.12.12.12:8080/demo/api").params(@{@"username":@"admin",@"password":@"123"}) get];
*/
