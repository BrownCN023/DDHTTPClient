//
//  DDHTTPClient.m
//
//  Created by liyebiao on 2020/7/15.
//

#import "DDHTTPClient.h"
#import <AFNetworking/AFNetworking.h>

#ifdef DEBUG
#define DDHTTPClientLog(format, ...) printf("-- (DDHTTPClientLog🍄) %s:(%d) --   %s\n\n", [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String] )
#else
#define DDHTTPClientLog(format, ...)
#endif


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
@property (nonatomic,copy) NSString * httpNotes;
@property (nonatomic,copy) NSString * httpUrl;
@property (nonatomic,strong) NSDictionary * httpHeader;
@property (nonatomic,strong) NSDictionary * httpParams;
@property (nonatomic,strong) NSArray<DDHTTPUploadComponent *> * httpUploadFiles;
@property (nonatomic,copy) DDHTTPProgressBlock httpProgress;
@property (nonatomic,copy) DDHTTPSuccessBlock httpSuccess;
@property (nonatomic,copy) DDHTTPLogicErrorBlock httpLogicError;
@property (nonatomic,copy) DDHTTPFailureBlock httpFailure;
@property (nonatomic,copy) DDHTTPDownloadDestinationBlock httpDownloadDestination;
@property (nonatomic,copy) DDHTTPDownloadCompletionBlock httpDownloadCompletion;
@property (nonatomic,copy) DDHTTPManagerConfigBlock httpManagerConfig;
@property (nonatomic,assign) DDHTTPMethod httpMethod;
@end




@implementation DDHTTPRequest

- (void)dealloc{
    DDHTTPClientLog(@"---- dealloc %@ ----",[self class]);
}

#pragma mark - Setter
- (DDHTTPRequest *(^)(NSString *))url{
    return ^(NSString * url){
        self.httpUrl = url;
        return self;
    };
}
- (DDHTTPRequest * _Nonnull (^)(NSString * _Nonnull))notes{
    return ^(NSString * notes){
        self.httpNotes = notes;
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

- (DDHTTPRequestLogicError)logicError{
    return ^(DDHTTPLogicErrorBlock callback){
        self.httpLogicError = callback;
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

- (DDHTTPRequest *(^)(void (^)(AFHTTPSessionManager *)))configSessionManager{
    return ^(void (^config)(AFHTTPSessionManager * manager)){
        self.httpManagerConfig = config;
        return self;
    };
}

- (DDHTTPRequest *(^)(DDHTTPMethod))method{
    return ^(DDHTTPMethod m){
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

+ (AFHTTPSessionManager *)createSessionManager
{
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
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

+ (void)configSessionManager:(AFHTTPSessionManager *)sessionManager url:(NSString *)url{
    //...
}

+ (NSURLSessionDataTask *)sendRequest:(DDHTTPRequest *)req
{
    if(![self checkNetwork:^(BOOL suc, NSError * _Nonnull error) {
        req.httpFailure(nil,error);
    }]){
        return nil;
    }
    AFHTTPSessionManager * manager = [self.class createSessionManager];
    [self.class configSessionManager:manager url:req.httpUrl];
    
    if(req.httpManagerConfig){
        req.httpManagerConfig(manager);
    }
    return [self taskWithMethod:req.httpMethod
                        manager:manager
                          notes:req.httpNotes
                            url:req.httpUrl
                        headers:req.httpHeader
                         params:req.httpParams
                       progress:req.httpProgress
                        success:req.httpSuccess
                     logicError:req.httpLogicError
                        failure:req.httpFailure];
}

+ (NSURLSessionDataTask *)sendUploadRequest:(DDHTTPRequest *)req
{
    if(![self checkNetwork:^(BOOL suc, NSError * _Nonnull error) {
        req.httpFailure(nil,error);
    }]){
        return nil;
    }

    AFHTTPSessionManager * manager = [self.class createSessionManager];
    if(req.httpManagerConfig){
        req.httpManagerConfig(manager);
    }
    return [self uploadWithManager:manager
                             notes:req.httpNotes
                               url:req.httpUrl
                           headers:req.httpHeader
                            params:req.httpParams
                       uploadfiles:req.httpUploadFiles
                          progress:req.httpProgress
                           success:req.httpSuccess
                        logicError:req.httpLogicError
                           failure:req.httpFailure];
}

+ (NSURLSessionDownloadTask *)sendDownloadRequest:(DDHTTPRequest *)req
{
    if(![self checkNetwork:^(BOOL suc, NSError * _Nonnull error) {
        req.httpFailure(nil,error);
    }]){
        return nil;
    }
    AFHTTPSessionManager * manager = [self.class createSessionManager];
    if(req.httpManagerConfig){
        req.httpManagerConfig(manager);
    }
    return [self downloadWithManager:manager
                               notes:req.httpNotes
                                 url:req.httpUrl
                             headers:req.httpHeader
                         destination:req.httpDownloadDestination
                          completion:req.httpDownloadCompletion
                            progress:req.httpProgress];
}


+ (BOOL)checkNetwork:(void (^)(BOOL suc,NSError * error))completion{
    BOOL suc = DDHTTPReachabilityManager.sharedManager.isReachable;
    
    if(completion){
        if(suc){
            completion(suc,nil);
        }else{
            NSError * msgError = [NSError errorWithDomain:NSLocalizedDescriptionKey code:NSURLErrorNetworkConnectionLost userInfo:@{ NSLocalizedDescriptionKey : @"error network connection lost"}];
            completion(suc,msgError);
        }
    }
    return suc;
}





+ (NSURLSessionDataTask *)taskWithMethod:(DDHTTPMethod)method
                                 manager:(AFHTTPSessionManager *)manager
                                   notes:(NSString *)notes
                                     url:(NSString *)url
                                 headers:(NSDictionary *)headers
                                  params:(NSDictionary *)params
                                progress:(DDHTTPProgressBlock)progress
                                 success:(DDHTTPSuccessBlock)success
                              logicError:(DDHTTPLogicErrorBlock)logicError
                                 failure:(DDHTTPFailureBlock)failure
{
    switch (method) {
            case DDHTTPMethodGet:
        {
            return [manager GET:url
                     parameters:params
                        headers:headers
                       progress:progress
                        success:[self handleSuccess:success failure:failure logicError:logicError notes:notes url:url method:@"GET" headers:headers params:params manager:manager]
                        failure:[self handleFailure:failure notes:notes url:url method:@"GET" headers:headers params:params manager:manager]];
        }
            break;
            case DDHTTPMethodPost:
        {
            return [manager POST:url
                      parameters:params
                         headers:headers
                        progress:progress
                         success:[self handleSuccess:success failure:failure logicError:logicError notes:notes url:url method:@"POST" headers:headers params:params manager:manager]
                         failure:[self handleFailure:failure notes:notes url:url method:@"POST" headers:headers params:params manager:manager]];
        }
            break;
            case DDHTTPMethodHead:
        {
            return [manager HEAD:url
                      parameters:params
                         headers:headers
                         success:^(NSURLSessionDataTask * _Nonnull task) {
                if(success){
                    success(task,nil);
                    //[self handleSuccess:success url:url headers:headers params:params]
                }
            }
                         failure:[self handleFailure:failure notes:notes url:url method:@"HEAD" headers:headers params:params manager:manager]];
        }
            break;
            case DDHTTPMethodPut:
        {
            return [manager PUT:url
                     parameters:params
                        headers:headers
                        success:[self handleSuccess:success failure:failure logicError:logicError notes:notes url:url method:@"PUT" headers:headers params:params manager:manager]
                        failure:[self handleFailure:failure notes:notes url:url method:@"PUT" headers:headers params:params manager:manager]];
        }
            break;
            case DDHTTPMethodPatch:
        {
            return [manager PATCH:url
                       parameters:params
                          headers:headers
                          success:[self handleSuccess:success failure:failure logicError:logicError notes:notes url:url method:@"PATCH" headers:headers params:params manager:manager]
                          failure:[self handleFailure:failure notes:notes url:url method:@"PATCH" headers:headers params:params manager:manager]];
        }
            break;
            case DDHTTPMethodDelete:
        {
            return [manager DELETE:url
                        parameters:params
                           headers:headers
                           success:[self handleSuccess:success failure:failure logicError:logicError notes:notes url:url method:@"DELETE" headers:headers params:params manager:manager]
                           failure:[self handleFailure:failure notes:notes url:url method:@"DELETE" headers:headers params:params manager:manager]];
        }
            break;
            
        default:
            break;
    }
    return nil;
}

+ (NSURLSessionDownloadTask *)downloadWithManager:(AFHTTPSessionManager *)manager
                                            notes:(NSString *)notes
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
                                      notes:(NSString *)notes
                                        url:(NSString *)url
                                    headers:(NSDictionary *)headers
                                     params:(NSDictionary *)params
                                uploadfiles:(NSArray<DDHTTPUploadComponent *> *)uploadFiles
                                   progress:(DDHTTPProgressBlock)progress
                                    success:(DDHTTPSuccessBlock)success
                                 logicError:(DDHTTPLogicErrorBlock)logicError
                                    failure:(DDHTTPFailureBlock)failure
{
    return [manager POST:url
              parameters:params
                 headers:headers
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
    }
                progress:progress
                 success:[self handleSuccess:success failure:failure logicError:logicError notes:notes url:url method:@"UPLOAD" headers:headers params:params manager:manager]
                 failure:[self handleFailure:failure notes:notes url:url method:@"UPLOAD" headers:headers params:params manager:manager]];
}

+ (DDHTTPSuccessBlock)handleSuccess:(DDHTTPSuccessBlock)success
                            failure:(DDHTTPFailureBlock)failure
                         logicError:(DDHTTPLogicErrorBlock _Nullable)logicError
                              notes:(NSString *)notes
                                url:(NSString *)url
                             method:(NSString *)method
                            headers:(NSDictionary *)headers
                             params:(NSDictionary *)params
                            manager:(AFHTTPSessionManager *)manager{
    return ^(NSURLSessionDataTask * task, id _Nullable response) {
        DDHTTPClientLog(@"🍄🍄🍄 http success.. \nurl:%@\nheaders:%@\nparams:%@\nresponse:%@",url,[self mergeHeaders:headers manager:manager],params,response);
        if(success){
            success(task,response);
        }
        [manager.session finishTasksAndInvalidate];
    };
}

+ (DDHTTPFailureBlock)handleFailure:(DDHTTPFailureBlock)failure
                              notes:(NSString *)notes
                                url:(NSString *)url
                             method:(NSString *)method
                            headers:(NSDictionary *)headers
                             params:(NSDictionary *)params
                            manager:(AFHTTPSessionManager *)manager{
    return ^(NSURLSessionDataTask * task, NSError *error) {
        DDHTTPClientLog(@"🍄🍄🍄 http failure.. \nurl:%@\nheaders:%@\nparams:%@\nerror:%@",url,[self mergeHeaders:headers manager:manager],params,error);
        if(failure){
            failure(task,error);
        }
        [manager.session finishTasksAndInvalidate];
    };
}

+ (NSDictionary *)mergeHeaders:(NSDictionary *)headers manager:(AFHTTPSessionManager *)manager{
    
    NSMutableDictionary * allHeaders = [NSMutableDictionary new];
    [allHeaders setValuesForKeysWithDictionary:manager.requestSerializer.HTTPRequestHeaders];
    [allHeaders setValuesForKeysWithDictionary:headers];
    return allHeaders;
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


@implementation NSURLSessionTask(taskBox)
- (void)addToTaskBox:(DDHTTPTaskBox *)taskBox{
    [taskBox addTask:self];
}
@end

@implementation NSURLSessionDataTask(taskBox)
- (void)addToTaskBox:(DDHTTPTaskBox *)taskBox{
    [taskBox addTask:self];
}
@end

@implementation NSURLSessionUploadTask(taskBox)
- (void)addToTaskBox:(DDHTTPTaskBox *)taskBox{
    [taskBox addTask:self];
}
@end

@implementation NSURLSessionDownloadTask(taskBox)
- (void)addToTaskBox:(DDHTTPTaskBox *)taskBox{
    [taskBox addTask:self];
}
@end
