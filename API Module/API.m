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
                                                                             @(kAPIEndpoint_GET_List):@"/getList",
                                                                             @(kAPIEndpoint_POST_List):@"/postList",
                                                                             @(kAPIEndpoint_MULTIPART_UploadImage):@"/uploadImage",
                                                                             @(kAPIEndpoint_PUT_EditList):@"/editList",
                                                                             @(kAPIEndpoint_DELETE_List):@"/deleteList",
                                                                             @(kAPIEndpoint_HEAD_List):@"/headList",
                                                                             @(kAPIEndpoint_PATCH_List):@"/patchList",
                                                                             
                                                                             @(kAPIEndpoint_GET_Test):@"/api/v2/ability/1/",
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
- (void)doRequest:(kHTTPMethodType)method apiType:(kAPIEndpoint)apiType responseType:(kResponseType)responseType parameters:(NSMutableDictionary *)parameters formData:(MultiPartFormDataBlock)formData progress:(ProgressBlock)progress success:(SuccessBlock)success failure:(FailBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@", HOST, _endPointDic[@(apiType)]];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // ## Set Response Serializer ##
    switch (responseType) {
        case kResponseType_HTTP:
        {
            AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
//            responseSerializer.stringEncoding = NSUTF8StringEncoding;
            manager.responseSerializer = responseSerializer;
        }
            break;
            
        case kResponseType_JSON:
        {
            AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
            manager.responseSerializer = responseSerializer;
        }
            break;
            
        case kResponseType_Image:
        {
            AFImageResponseSerializer *responseSerializer = [AFImageResponseSerializer serializer];
            manager.responseSerializer = responseSerializer;
        }
            break;
            
        case kResponseType_XML:
        {
            AFXMLParserResponseSerializer *responseSerializer = [AFXMLParserResponseSerializer serializer];
            manager.responseSerializer = responseSerializer;
        }
            break;
            
        case kResponseType_PropertyList:
        {
            AFPropertyListResponseSerializer *responseSerializer = [AFPropertyListResponseSerializer serializer];
            manager.responseSerializer = responseSerializer;
        }
            break;
            
        default:
        {
            AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
            manager.responseSerializer = responseSerializer;
        }
            break;
    }
    
    switch (apiType) {
        default:
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
    }
    
    switch (method) {
        case kHTTPMethodType_GET:
        {
            self.currentTask = [manager GET:url parameters:parameters progress:progress success:success failure:failure];
        }
            break;
            
        case kHTTPMethodType_POST:
        {
            self.currentTask = [manager POST:url parameters:parameters progress:progress success:success failure:failure];
        }
            break;
            
        case kHTTPMethodType_POST_MultiPart:
        {
            self.currentTask = [manager POST:url parameters:parameters constructingBodyWithBlock:formData progress:progress success:success failure:failure];
        }
            break;
            
        case kHTTPMethodType_PUT:
        {
            self.currentTask = [manager PUT:url parameters:parameters success:success failure:failure];
        }
            break;
            
        case kHTTPMethodType_DELETE:
        {
            self.currentTask = [manager DELETE:url parameters:parameters success:success failure:failure];
        }
            break;
            
        case kHTTPMethodType_HEAD:
        {
            self.currentTask = [manager HEAD:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task) {
                success(task, nil);
            } failure:failure];
        }
            break;
            
        case kHTTPMethodType_PATCH:
        {
            self.currentTask = [manager PATCH:url parameters:parameters success:success failure:failure];
        }
            break;
    }
    
    [self.arrayOfAllTasks addObject:self.currentTask];
}

#pragma mark - API Request Methods
- (void)getEndpoint:(kAPIEndpoint)endpoint responseType:(kResponseType)responseType parameters:(NSMutableDictionary *)parameters progress:(ProgressBlock)progress success:(SuccessBlock)success failure:(FailBlock)failure
{
    [self doRequest:kHTTPMethodType_GET apiType:endpoint responseType:responseType parameters:parameters formData:nil progress:progress success:success failure:failure];
}

- (void)postEndpoint:(kAPIEndpoint)endpoint responseType:(kResponseType)responseType parameters:(NSMutableDictionary *)parameters progress:(ProgressBlock)progress success:(SuccessBlock)success failure:(FailBlock)failure
{
    [self doRequest:kHTTPMethodType_GET apiType:endpoint responseType:responseType parameters:parameters formData:nil progress:progress success:success failure:failure];
}

- (void)multipartEndpoint:(kAPIEndpoint)endpoint responseType:(kResponseType)responseType formData:(MultiPartFormDataBlock)formData parameters:(NSMutableDictionary *)parameters progress:(ProgressBlock)progress success:(SuccessBlock)success failure:(FailBlock)failure
{
    [self doRequest:kHTTPMethodType_GET apiType:endpoint responseType:responseType parameters:parameters formData:formData progress:progress success:success failure:failure];
}
- (void)putEndpoint:(kAPIEndpoint)endpoint responseType:(kResponseType)responseType parameters:(NSMutableDictionary *)parameters  success:(SuccessBlock)success failure:(FailBlock)failure
{
    [self doRequest:kHTTPMethodType_GET apiType:endpoint responseType:responseType parameters:parameters formData:nil progress:nil success:success failure:failure];
}

- (void)deleteEndpoint:(kAPIEndpoint)endpoint responseType:(kResponseType)responseType parameters:(NSMutableDictionary *)parameters success:(SuccessBlock)success failure:(FailBlock)failure
{
    [self doRequest:kHTTPMethodType_GET apiType:endpoint responseType:responseType parameters:parameters formData:nil progress:nil success:success failure:failure];
}

- (void)headEndpoint:(kAPIEndpoint)endpoint responseType:(kResponseType)responseType parameters:(NSMutableDictionary *)parameters success:(SuccessBlock)success failure:(FailBlock)failure
{
    [self doRequest:kHTTPMethodType_GET apiType:endpoint responseType:responseType parameters:parameters formData:nil progress:nil success:success failure:failure];
}

- (void)patchEndpoint:(kAPIEndpoint)endpoint responseType:(kResponseType)responseType parameters:(NSMutableDictionary *)parameters success:(SuccessBlock)success failure:(FailBlock)failure
{
    [self doRequest:kHTTPMethodType_GET apiType:endpoint responseType:responseType parameters:parameters formData:nil progress:nil success:success failure:failure];
}

@end
