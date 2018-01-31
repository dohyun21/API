//
//  API.m
//
//
//  Created by kdh on 2018. 1. 31..
//  Copyright © 2018년 Kim Do Hyun. All rights reserved.
//

#import "API.h"

@implementation API

+ (API *)sharedInstance {
    static API *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[API alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.arrayOfAllTasks = [[NSMutableArray alloc] init];
        // APIType EndPoint 주소 지정
        self.endPointDic = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                             @(kAPIType_GET_List):@"/getList",
                                                                             }];
    }
    return self;
}

#pragma mark - # Public Methods #
/*! @brief Binary Data to NSString */
+ (NSString *)binaryDataConversionToString:(NSData *)data {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (id)failResponseStringWithError:(NSError *)error {
    NSData *responseErrorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    NSError *jsonError;
    id responseErrorJSON = nil;
    if (responseErrorData != nil) {
        responseErrorJSON = [NSJSONSerialization JSONObjectWithData:responseErrorData options:0 error:&jsonError];
        return jsonError != nil ? jsonError : responseErrorJSON;
    } else {
        return error;
    }
}

+ (NSInteger)checkStatusCodeWithError:(NSURLSessionDataTask *)task {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
    
    return httpResponse.statusCode;
}

/*!
 * @brief 공통파라미터 생성
 * @discussion
 bar : 파라미터 변수값
 * @return NSMutableDictionary - 필수 파라미터 반환
 */
- (NSMutableDictionary *)makeRequiredParameters {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
//    [parameters setValue:@"foo" forKey:@"bar"];
    return parameters;
}

- (void)cancelCurrentRequest {
    [self.currentTask cancel];
    [self.arrayOfAllTasks removeObject:self.currentTask];
    self.currentTask = nil;
}

- (void)cancelAllRequest {
    for (NSURLSessionTask *task in self.arrayOfAllTasks) {
        [task cancel];
    }
    [self.arrayOfAllTasks removeAllObjects];
}

#pragma mark - # Private Methods #
// URLEncoding
-(NSString *)URLEncode:(NSString *)string {
    return [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}

// 최종 Request
- (void)doRequestWithManager:(AFHTTPSessionManager *)manager method:(kHTTPMethodType)method url:(NSString *)url parameter:(id)parameter formData:(MultiPartFormDataBlock)formData progress:(ProgressBlock)progress success:(SuccessBlock)success fail:(FailBlock)fail
{
    switch (method) {
        case kHTTPMethodType_GET:
        {
            self.currentTask = [manager GET:url parameters:parameter progress:progress success:success failure:fail];
        }
            break;
            
        case kHTTPMethodType_POST:
        {
            self.currentTask = [manager POST:url parameters:parameter progress:progress success:success failure:fail];
        }
            break;
            
        case kHTTPMethodType_POST_MultiPart:
        {
            self.currentTask = [manager POST:url parameters:parameter constructingBodyWithBlock:formData progress:progress success:success failure:fail];
        }
            break;
            
        case kHTTPMethodType_PUT:
        {
            self.currentTask = [manager PUT:url parameters:parameter success:success failure:fail];
        }
            break;
            
        case kHTTPMethodType_DELETE:
        {
            self.currentTask = [manager DELETE:url parameters:parameter success:success failure:fail];
        }
            break;
            
        case kHTTPMethodType_HEAD:
        {
            self.currentTask = [manager HEAD:url parameters:parameter success:^(NSURLSessionDataTask * _Nonnull task) {
                success(task, nil);
            } failure:fail];
        }
            break;
            
        case kHTTPMethodType_PATCH:
        {
            self.currentTask = [manager PATCH:url parameters:parameter success:success failure:fail];
        }
            break;
    }
    
    [self.arrayOfAllTasks addObject:self.currentTask];
}

#pragma mark - API Request Methods
- (void)doRequestMethodType:(kHTTPMethodType)method apiType:(kAPIType)apiType parameter:(NSMutableDictionary *)parameter formData:(MultiPartFormDataBlock)formData progress:(ProgressBlock)progress success:(SuccessBlock)success fail:(FailBlock)fail
{
    NSString *url = [NSString stringWithFormat:@"%@%@", HOST, _endPointDic[@(apiType)]];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    switch (apiType) {
        default:
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
    }
    [self doRequestWithManager:manager method:method url:url parameter:parameter formData:formData progress:progress success:success fail:fail];
}

- (void)doRequestMethodType:(kHTTPMethodType)method url:(NSString *)url header:(NSDictionary *)header parameter:(NSMutableDictionary *)parameter formData:(MultiPartFormDataBlock)formData progress:(ProgressBlock)progress success:(SuccessBlock)success fail:(FailBlock)fail
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // ## Request Type Setting ##
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];                   // 기본
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];                   // JSON
//    manager.requestSerializer = [AFPropertyListRequestSerializer serializer];           // XML
    
    // Header 지정
    if (header != nil) {
        for (NSString *key in header.allKeys) {
            [manager.requestSerializer setValue:[header objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    // ## Response Type Setting ##
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];                 // 기본
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];                 // JSON
//    manager.responseSerializer = [AFPropertyListResponseSerializer serializer];         // XML
//    manager.responseSerializer = [AFImageResponseSerializer serializer];                // Image
    
    [self doRequestWithManager:manager method:method url:url parameter:parameter formData:formData progress:progress success:success fail:fail];
}

@end
