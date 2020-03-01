//
//  DDHTTPClient.m
//  DDToolboxExample
//
//  Created by brown on 2018/5/10.
//  Copyright © 2018年 ABiang. All rights reserved.
//

#import "DDHTTPClient.h"

#pragma mark - DDHTTPUploadModel

@implementation DDHTTPUploadComponent

- (instancetype)initWithFileType:(DDHTTPUploadComponentType)fileType
                            name:(NSString *)name
                            data:(NSData *)data
                        filename:(NSString *)filename{
    if(self = [super init]){
        self.fileType = fileType;
        self.data = data;
        self.fileName = filename;
        self.name = name;
    }
    return self;
}

- (instancetype)initWithFileType:(DDHTTPUploadComponentType)fileType
                            name:(NSString *)name
                        filePath:(NSString *)filePath
                        filename:(NSString *)filename
                        mimeType:(NSString *)mimeType{
    if(self = [super init]){
        self.fileType = fileType;
        self.filePath = filePath;
        self.fileName = filename;
        self.mimeType = mimeType;
        self.name = name;
    }
    return self;
}

@end





@interface DDHTTPRequest()
@property (nonatomic,copy) NSString * httpUrl;
@property (nonatomic,strong) NSDictionary * httpHeader;
@property (nonatomic,strong) NSDictionary * httpParams;
@property (nonatomic,strong) NSArray<DDHTTPUploadComponent *> * httpUploadFiles;
@property (nonatomic,copy) DDHTTPProgressBlock httpProgress;
@property (nonatomic,copy) DDHTTPSuccessBlock httpSuccess;
@property (nonatomic,copy) DDHTTPFailureBlock httpFailure;
@property (nonatomic,copy) DDHTTPDownloadDestinationBlock httpDownloadDestination;
@property (nonatomic,copy) DDHTTPDownloadCompletionBlock httpDownloadCompletion;
@property (nonatomic,copy) DDHTTPManagerConfigBlock httpManagerConfig;
@property (nonatomic,assign) DDHTTP_Method httpMethod;
@end




@implementation DDHTTPRequest

- (void)dealloc{
#ifdef DEBUG
    NSLog(@"---- dealloc %@ ----",[self class]);
#endif
}

#pragma mark - Setter
- (DDHTTPRequest *(^)(NSString *))url{
    return ^(NSString * url){
        self.httpUrl = url;
        return self;
    };
}

- (DDHTTPRequest *(^)(NSDictionary *))header{
    return ^(NSDictionary * header){
        self.httpHeader = header;
        return self;
    };
}

- (DDHTTPRequest *(^)(NSDictionary *))params{
    return ^(NSDictionary * params){
        self.httpParams = params;
        return self;
    };
}

- (DDHTTPRequest *(^)(NSArray<DDHTTPUploadComponent *> *))uploadFiles{
    return ^(NSArray<DDHTTPUploadComponent *> * uploadFiles){
        self.httpUploadFiles = uploadFiles;
        return self;
    };
}

- (DDHTTPRequestDownloadDestination)downloadDestination{
    return ^(DDHTTPDownloadDestinationBlock callback){
        self.httpDownloadDestination = callback;
        return self;
    };
}

- (DDHTTPRequestDownloadCompletion)downloadCompletion{
    return ^(DDHTTPDownloadCompletionBlock callback){
        self.httpDownloadCompletion = callback;
        return self;
    };
}

- (DDHTTPRequestSuccess)success{
    return ^(DDHTTPSuccessBlock callback){
        self.httpSuccess = callback;
        return self;
    };
}

- (DDHTTPRequestFailure)failure{
    return ^(DDHTTPFailureBlock callback){
        self.httpFailure = callback;
        return self;
    };
}

- (DDHTTPRequestProgress)progress{
    return ^(DDHTTPProgressBlock callback){
        self.httpProgress = callback;
        return self;
    };
}

- (DDHTTPRequest *(^)(void (^)(AFHTTPSessionManager *)))managerConfig{
    return ^(void (^config)(AFHTTPSessionManager * manager)){
        self.httpManagerConfig = config;
        return self;
    };
}

- (DDHTTPRequest *(^)(DDHTTP_Method))method{
    return ^(DDHTTP_Method m){
        self.httpMethod = m;
        return self;
    };
}

@end





#pragma mark - DDHTTPClient
@implementation DDHTTPClient

+ (DDHTTPRequest *)createRequest
{
    return [[DDHTTPRequest alloc] init];
}

+ (AFHTTPSessionManager *)createManager
{
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //        manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"text/html",
                                                         @"text/xml",
                                                         @"text/plain",
                                                         @"application/json",
                                                         nil];
    manager.operationQueue.maxConcurrentOperationCount = 5;
    manager.requestSerializer.timeoutInterval = 30;
    return manager;
}

+ (NSURLSessionDataTask *)sendRequest:(DDHTTPRequest *)req
{
    AFHTTPSessionManager * manager = [self.class createManager];
    if(req.httpManagerConfig){
        req.httpManagerConfig(manager);
    }
    return [self taskWithMethod:req.httpMethod
                              manager:manager
                                  url:req.httpUrl
                              headers:req.httpHeader
                               params:req.httpParams
                             progress:req.httpProgress
                              success:req.httpSuccess
                              failure:req.httpFailure];
}

+ (NSURLSessionDataTask *)sendUploadRequest:(DDHTTPRequest *)req
{
    AFHTTPSessionManager * manager = [self.class createManager];
    if(req.httpManagerConfig){
        req.httpManagerConfig(manager);
    }
    return [self uploadWithManager:manager
                               url:req.httpUrl
                           headers:req.httpHeader
                            params:req.httpParams
                       uploadfiles:req.httpUploadFiles
                          progress:req.httpProgress
                           success:req.httpSuccess
                           failure:req.httpFailure];
}

+ (NSURLSessionDownloadTask *)sendDownloadRequest:(DDHTTPRequest *)req
{
    AFHTTPSessionManager * manager = [self.class createManager];
    if(req.httpManagerConfig){
        req.httpManagerConfig(manager);
    }
    return [self downloadWithManager:manager
                                 url:req.httpUrl
                             headers:req.httpHeader
                         destination:req.httpDownloadDestination
                          completion:req.httpDownloadCompletion
                            progress:req.httpProgress];
}









+ (NSURLSessionDataTask *)taskWithMethod:(DDHTTP_Method)method
                                 manager:(AFHTTPSessionManager *)manager
                                     url:(NSString *)url
                                 headers:(NSDictionary *)headers
                                  params:(NSDictionary *)params
                                progress:(DDHTTPProgressBlock)progress
                                 success:(DDHTTPSuccessBlock)success
                                 failure:(DDHTTPFailureBlock)failure
{
    
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
        [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    
    switch (method) {
            case DDHTTP_Method_Get:
        {
            return [manager GET:url
                     parameters:params
                       progress:progress
                        success:success
                        failure:failure];
        }
            break;
            case DDHTTP_Method_Post:
        {
            return [manager POST:url
                      parameters:params
                        progress:progress
                         success:success
                         failure:failure];
        }
            break;
            case DDHTTP_Method_Head:
        {
            return [manager HEAD:url
                      parameters:params
                         success:^(NSURLSessionDataTask * _Nonnull task) {
                             if(success){
                                 success(task,nil);
                             }
                         } failure:failure];
        }
            break;
            case DDHTTP_Method_Put:
        {
            return [manager PUT:url
                     parameters:params
                        success:success
                        failure:failure];
        }
            break;
            case DDHTTP_Method_Patch:
        {
            return [manager PATCH:url
                       parameters:params
                          success:success
                          failure:failure];
        }
            break;
            case DDHTTP_Method_Delete:
        {
            return [manager DELETE:url
                     parameters:params
                        success:success
                        failure:failure];
        }
            break;
            
        default:
            break;
    }
    return nil;
}

+ (NSURLSessionDownloadTask *)downloadWithManager:(AFHTTPSessionManager *)manager
                                              url:(NSString *)url
                                          headers:(NSDictionary *)headers
                                      destination:(DDHTTPDownloadDestinationBlock)destination
                                       completion:(DDHTTPDownloadCompletionBlock)completion
                                         progress:(DDHTTPProgressBlock)progress
{
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
        [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDownloadTask * download = [manager downloadTaskWithRequest:request
                                                                  progress:progress
                                                               destination:destination
                                                         completionHandler:completion];
    [download resume];
    return download;
}

+ (NSURLSessionDataTask *)uploadWithManager:(AFHTTPSessionManager *)manager
                                        url:(NSString *)url
                                    headers:(NSDictionary *)headers
                                     params:(NSDictionary *)params
                                uploadfiles:(NSArray<DDHTTPUploadComponent *> *)uploadFiles
                                   progress:(DDHTTPProgressBlock)progress
                                    success:(DDHTTPSuccessBlock)success
                                    failure:(DDHTTPFailureBlock)failure
{
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
        [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    return [manager POST:url
              parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [uploadFiles enumerateObjectsUsingBlock:^(DDHTTPUploadComponent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(obj.fileType == DDHTTPUploadComponentTypeData){
                [formData appendPartWithFileData:obj.data name:obj.name fileName:obj.fileName mimeType:obj.mimeType];
            }
            if(obj.fileType == DDHTTPUploadComponentTypeFilePath){
                if(obj.fileName){
                    [formData appendPartWithFileURL:[NSURL fileURLWithPath:obj.filePath] name:obj.name fileName:obj.fileName mimeType:obj.mimeType error:nil];
                }else{
                    [formData appendPartWithFileURL:[NSURL fileURLWithPath:obj.filePath] name:obj.name error:nil];
                }
            }
        }];
    }  progress:progress
        success:success
        failure:failure];
}

@end


@interface DDHTTPTaskBox(){
    NSHashTable * _delegates;
}
@end

@implementation DDHTTPTaskBox
+ (DDHTTPTaskBox *)createTaskBox{
    return [[DDHTTPTaskBox alloc] init];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return self;
}
- (void)addTask:(NSURLSessionTask *)task
{
    [_delegates addObject:task];
}
- (void)removeTask:(NSURLSessionTask *)task
{
    [task cancel];
    [_delegates removeObject:task];
}
- (void)removeAllTask
{
    [_delegates.allObjects enumerateObjectsUsingBlock:^(NSURLSessionTask * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cancel];
    }];
    [_delegates removeAllObjects];
}

@end
