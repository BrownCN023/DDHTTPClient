//
//  DDHTTPClient.h
//
//  Created by liyebiao on 2020/7/15.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "DDHTTPReachabilityManager.h"

NS_ASSUME_NONNULL_BEGIN

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

typedef NS_ENUM(NSInteger,DDHTTPMethod) {
    DDHTTPMethodGet = 0,
    DDHTTPMethodPost,
    DDHTTPMethodHead,
    DDHTTPMethodPut,
    DDHTTPMethodPatch,
    DDHTTPMethodDelete
};

typedef void (^DDHTTPProgressBlock)(NSProgress *downloadProgress);
typedef void (^DDHTTPSuccessBlock)(NSURLSessionDataTask * task, id _Nullable response);
typedef void (^DDHTTPLogicErrorBlock)(NSURLSessionDataTask * task, id _Nullable response, NSString * _Nullable errMsg);
typedef void (^DDHTTPFailureBlock)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error);

typedef NSURL * _Nullable (^DDHTTPDownloadDestinationBlock)(NSURL * targetPath, NSURLResponse * response);
typedef void (^DDHTTPDownloadCompletionBlock)(NSURLResponse * response, NSURL * filePath, NSError * error);
typedef void (^DDHTTPManagerConfigBlock)(AFHTTPSessionManager * manager);

@class DDHTTPRequest;
typedef DDHTTPRequest *_Nullable(^DDHTTPRequestDownloadDestination)(DDHTTPDownloadDestinationBlock callBlock);
typedef DDHTTPRequest *_Nullable(^DDHTTPRequestDownloadCompletion)(DDHTTPDownloadCompletionBlock callBlock);
typedef DDHTTPRequest *_Nullable(^DDHTTPRequestProgress)(DDHTTPProgressBlock callBlock);
typedef DDHTTPRequest *_Nullable(^DDHTTPRequestSuccess)(DDHTTPSuccessBlock callBlock);
typedef DDHTTPRequest *_Nullable(^DDHTTPRequestLogicError)(DDHTTPLogicErrorBlock callBlock);
typedef DDHTTPRequest *_Nullable(^DDHTTPRequestFailure)(DDHTTPFailureBlock callBlock);


@interface DDHTTPRequest : NSObject
@property (nonatomic,strong,readonly) DDHTTPRequest * (^notes)(NSString * notes);
@property (nonatomic,strong,readonly) DDHTTPRequest * (^url)(NSString * url);
@property (nonatomic,strong,readonly) DDHTTPRequest * (^header)(NSDictionary * _Nullable header);
@property (nonatomic,strong,readonly) DDHTTPRequest * (^params)(NSDictionary * _Nullable params);
@property (nonatomic,strong,readonly) DDHTTPRequest * (^uploadFiles)(NSArray<DDHTTPUploadComponent *> * files);
@property (nonatomic,strong,readonly) DDHTTPRequestDownloadDestination downloadDestination;
@property (nonatomic,strong,readonly) DDHTTPRequestDownloadCompletion downloadCompletion;
@property (nonatomic,strong,readonly) DDHTTPRequestProgress progress;
@property (nonatomic,strong,readonly) DDHTTPRequestSuccess success;
@property (nonatomic,strong,readonly) DDHTTPRequestLogicError logicError; //逻辑错误为暂未实现，可以重写handleSuccess实现
@property (nonatomic,strong,readonly) DDHTTPRequestFailure failure;
@property (nonatomic,strong,readonly) DDHTTPRequest * (^configSessionManager)(void (^)(AFHTTPSessionManager * manager));
@property (nonatomic,strong,readonly) DDHTTPRequest * (^method)(DDHTTPMethod m);
@end


@interface DDHTTPClient : NSObject
//创建SessionManager
+ (AFHTTPSessionManager *)createSessionManager;
//配置SessionManager
+ (void)configSessionManager:(AFHTTPSessionManager *)sessionManager url:(NSString *)url;
//创建请求
+ (DDHTTPRequest *)createRequest;
//发送请求
+ (NSURLSessionDataTask *)sendRequest:(DDHTTPRequest *)req;
//发送上传
+ (NSURLSessionDataTask *)sendUploadRequest:(DDHTTPRequest *)req;
//发送下载
+ (NSURLSessionDownloadTask *)sendDownloadRequest:(DDHTTPRequest *)req;

//检查网络是否异常
+ (BOOL)checkNetwork:(void (^)(BOOL suc,NSError * error))completion;

//处理成功
+ (DDHTTPSuccessBlock)handleSuccess:(DDHTTPSuccessBlock _Nullable)success
                            failure:(DDHTTPFailureBlock _Nullable)failure
                         logicError:(DDHTTPLogicErrorBlock _Nullable)logicError
                              notes:(NSString *)notes
                                url:(NSString *)url
                             method:(NSString *)method
                            headers:(NSDictionary * _Nullable)headers
                             params:(NSDictionary * _Nullable)params
                            manager:(AFHTTPSessionManager *)manager;
//处理失败
+ (DDHTTPFailureBlock)handleFailure:(DDHTTPFailureBlock _Nullable)failure
                              notes:(NSString *)notes
                                url:(NSString *)url
                             method:(NSString *)method
                            headers:(NSDictionary * _Nullable)headers
                             params:(NSDictionary * _Nullable)params
                            manager:(AFHTTPSessionManager *)manager;
//合并请求头 - 用于打印信息
+ (NSDictionary *)mergeHeaders:(NSDictionary *)headers manager:(AFHTTPSessionManager *)manager;
@end

//任务盒子，主要处理界面退出后，取消还在执行的请求
@interface DDHTTPTaskBox : NSObject

+ (DDHTTPTaskBox *)createTaskBox;
- (void)addTask:(NSURLSessionTask *)task;
- (void)removeTask:(NSURLSessionTask *)task;
- (void)removeAllTask;

@end


@interface NSURLSessionTask(taskBox)
- (void)addToTaskBox:(DDHTTPTaskBox *)taskBox;
@end

@interface NSURLSessionDataTask(taskBox)
- (void)addToTaskBox:(DDHTTPTaskBox *)taskBox;
@end

@interface NSURLSessionUploadTask(taskBox)
- (void)addToTaskBox:(DDHTTPTaskBox *)taskBox;
@end

@interface NSURLSessionDownloadTask(taskBox)
- (void)addToTaskBox:(DDHTTPTaskBox *)taskBox;
@end

/**
 e.g.
 
 DDHTTPRequest * request = DDHTTPClient.createRequest
 .notes(@"这里一个接口备注")
 .method(DDHTTPMethodGet)
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

NS_ASSUME_NONNULL_END
