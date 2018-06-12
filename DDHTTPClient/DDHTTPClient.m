//
//  DDHTTPClient.m
//  DDToolboxExample
//
//  Created by brown on 2018/5/10.
//  Copyright © 2018年 ABiang. All rights reserved.
//

#import "DDHTTPClient.h"

#pragma mark - DDHTTPUploadModel

@implementation DDHTTPUploadModel

- (instancetype)initWithFileType:(DDHTTPUploadFileType)fileType name:(NSString *)name data:(NSData *)data filename:(NSString *)filename{
    if(self = [super init]){
        self.fileType = fileType;
        self.data = data;
        self.fileName = filename;
        self.name = name;
    }
    return self;
}

- (instancetype)initWithFileType:(DDHTTPUploadFileType)fileType name:(NSString *)name filePath:(NSString *)filePath filename:(NSString *)filename mimeType:(NSString *)mimeType{
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

#pragma mark - DDHTTPClient

@interface DDHTTPClient()

@property (nonatomic,copy) NSString * httpUrl;
@property (nonatomic,strong) NSDictionary * httpHeader;
@property (nonatomic,strong) NSDictionary * httpParams;
@property (nonatomic,strong) NSArray<DDHTTPUploadModel *> * httpUploadFiles;
@property (nonatomic,copy) DDHTTPProgressCallback httpProgress;
@property (nonatomic,copy) DDHTTPSuccessCallback httpSuccess;
@property (nonatomic,copy) DDHTTPFailureCallback httpFailure;
@property (nonatomic,copy) DDHTTPDownloadDestination httpDownloadDestination;
@property (nonatomic,copy) DDHTTPDownloadCompletion httpDownloadCompletion;

@end

#pragma mark - DDHTTPClient
@implementation DDHTTPClient

- (void)dealloc{
#ifdef DEBUG
    NSLog(@"---- dealloc %@ ----",[self class]);
#endif
}

- (instancetype)init{
    if(self = [super init]){
        
    }
    return self;
}

#pragma mark - Setter
- (DDHTTPRequestURL)url{
    return ^(NSString * url){
        self.httpUrl = url;
        return self;
    };
}

- (DDHTTPRequestHeader)header{
    return ^(NSDictionary * header){
        self.httpHeader = header;
        return self;
    };
}

- (DDHTTPRequestParams)params{
    return ^(NSDictionary * params){
        self.httpParams = params;
        return self;
    };
}

- (DDHTTPRequestUploadFile)uploadfiles{
    return ^(NSArray<DDHTTPUploadModel *> * uploadFiles){
        self.httpUploadFiles = uploadFiles;
        return self;
    };
}

- (DDHTTPRequestDownloadDestination)downloadDestination{
    return ^(DDHTTPDownloadDestination callback){
        self.httpDownloadDestination = callback;
        return self;
    };
}

- (DDHTTPRequestDownloadCompletion)downloadCompletion{
    return ^(DDHTTPDownloadCompletion callback){
        self.httpDownloadCompletion = callback;
        return self;
    };
}

- (DDHTTPRequestSuccess)success{
    return ^(DDHTTPSuccessCallback callback){
        self.httpSuccess = callback;
        return self;
    };
}

- (DDHTTPRequestFailure)failure{
    return ^(DDHTTPFailureCallback callback){
        self.httpFailure = callback;
        return self;
    };
}

- (DDHTTPRequestProgress)progress{
    return ^(DDHTTPProgressCallback callback){
        self.httpProgress = callback;
        return self;
    };
}

- (NSURLSessionDataTask *)head{
    AFHTTPSessionManager * manager = [[self class] httpManager];
    return [DDHTTPClient taskWithMethod:DDHTTPMethodHead manager:manager url:self.httpUrl headers:self.httpHeader params:self.httpParams progress:self.httpProgress success:self.httpSuccess failure:self.httpFailure];
}
- (NSURLSessionDataTask *)get{
    AFHTTPSessionManager * manager = [[self class] httpManager];
    return [DDHTTPClient taskWithMethod:DDHTTPMethodGet manager:manager url:self.httpUrl headers:self.httpHeader params:self.httpParams progress:self.httpProgress success:self.httpSuccess failure:self.httpFailure];
}
- (NSURLSessionDataTask *)post{
    AFHTTPSessionManager * manager = [[self class] httpManager];
    return [DDHTTPClient taskWithMethod:DDHTTPMethodPost manager:manager url:self.httpUrl headers:self.httpHeader params:self.httpParams progress:self.httpProgress success:self.httpSuccess failure:self.httpFailure];
}
- (NSURLSessionDataTask *)upload{
    AFHTTPSessionManager * manager = [[self class] httpManager];
    return [DDHTTPClient uploadWithManager:manager url:self.httpUrl headers:self.httpHeader params:self.httpParams uploadfiles:self.httpUploadFiles progress:self.httpProgress success:self.httpSuccess failure:self.httpFailure];
}
- (NSURLSessionDownloadTask *)download{
    AFHTTPSessionManager * manager = [[self class] httpManager];
    return [DDHTTPClient downloadWithManager:manager url:self.httpUrl headers:self.httpHeader destination:self.httpDownloadDestination completion:self.httpDownloadCompletion progress:self.httpProgress];
}

#pragma mark - AFN
+ (AFHTTPSessionManager *)httpManager:(void (^)(AFHTTPSessionManager * manager))config{
    static AFHTTPSessionManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        if(config){
            config(manager);
        }
    });
    return manager;
}
+ (AFHTTPSessionManager *)httpManager{
    return [self httpManager:^(AFHTTPSessionManager *manager) {
        [self configSerializer:manager];
    }];
}

+ (void)configSerializer:(AFHTTPSessionManager *)manager{
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                         @"text/html",
                                                         @"text/xml",
                                                         @"text/plain",
                                                         @"application/json",
                                                         nil];
    manager.operationQueue.maxConcurrentOperationCount = 5;
    manager.requestSerializer.timeoutInterval = 30;
}

+ (NSURLSessionDownloadTask *)downloadWithManager:(AFHTTPSessionManager *)manager
                                              url:(NSString *)url
                                          headers:(NSDictionary *)headers
                                      destination:(DDHTTPDownloadDestination)destination
                                       completion:(DDHTTPDownloadCompletion)completion
                                         progress:(DDHTTPProgressCallback)progress{
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
                                uploadfiles:(NSArray<DDHTTPUploadModel *> *)uploadFiles
                                   progress:(DDHTTPProgressCallback)progress
                                    success:(DDHTTPSuccessCallback)success
                                    failure:(DDHTTPFailureCallback)failure{
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
        [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    return [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [uploadFiles enumerateObjectsUsingBlock:^(DDHTTPUploadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(obj.fileType == DDHTTPUploadFileTypeData){
                [formData appendPartWithFileData:obj.data name:obj.name fileName:obj.fileName mimeType:obj.mimeType];
            }
            if(obj.fileType == DDHTTPUploadFileTypeFilePath){
                if(obj.fileName){
                    [formData appendPartWithFileURL:[NSURL fileURLWithPath:obj.filePath] name:obj.name fileName:obj.fileName mimeType:obj.mimeType error:nil];
                }else{
                    [formData appendPartWithFileURL:[NSURL fileURLWithPath:obj.filePath] name:obj.name error:nil];
                }
            }
        }];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if(progress){
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if(success){
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(failure){
            failure(error);
        }
    }];
}

+ (NSURLSessionDataTask *)taskWithMethod:(DDHTTPMethod)method
                                 manager:(AFHTTPSessionManager *)manager
                                     url:(NSString *)url
                                 headers:(NSDictionary *)headers
                                  params:(NSDictionary *)params
                                progress:(DDHTTPProgressCallback)progress
                                 success:(DDHTTPSuccessCallback)success
                                 failure:(DDHTTPFailureCallback)failure{
    
    void (^reqProgress)(NSProgress *) = ^(NSProgress *downloadProgress){
        if(progress){
            progress(downloadProgress);
        }
    };
    
    void (^reqSuccess)(NSURLSessionDataTask *, id _Nullable) = ^(NSURLSessionDataTask *task, id _Nullable responseObject){
        if(success){
            success(responseObject);
        }
    };
    
    void (^reqFailure)(NSURLSessionDataTask * _Nullable , NSError *) = ^(NSURLSessionDataTask * _Nullable task, NSError *error){
        if(failure){
            failure(error);
        }
    };
    
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
        [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    
    switch (method) {
        case DDHTTPMethodGet:
        {
            return [manager GET:url
                     parameters:params
                       progress:reqProgress
                        success:reqSuccess
                        failure:reqFailure];
        }
            break;
        case DDHTTPMethodPost:
        {
            return [manager POST:url
                      parameters:params
                        progress:reqProgress
                         success:reqSuccess
                         failure:reqFailure];
        }
            break;
        case DDHTTPMethodHead:
        {
            return [manager HEAD:url
                      parameters:params
                         success:^(NSURLSessionDataTask * _Nonnull task) {
                             if(success){
                                 success(task);
                             }
                         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                             if(failure){
                                 failure(error);
                             }
                         }];
        }
            break;
            
        default:
            break;
    }
    return nil;
}

+ (DDHTTPClient *)createClient{
    return [[[self class] alloc] init];
}

@end

