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
                                                                             @(kAPIType_POST_List):@"/postList",
                                                                             @(kAPIType_POST_UploadImage):@"/uploadImage",
                                                                             @(kAPIType_PUT_EditList):@"/editList",
                                                                             @(kAPIType_DELETE_List):@"/deleteList",
                                                                             @(kAPIType_HEAD_List):@"/headList",
                                                                             @(kAPIType_PATCH_List):@"/patchList",
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
- (void)doRequest:(kHTTPMethodType)method apiType:(kAPIType)apiType parameters:(NSMutableDictionary *)parameters formData:(MultiPartFormDataBlock)formData progress:(ProgressBlock)progress success:(SuccessBlock)success failure:(FailBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@%@", HOST, _endPointDic[@(apiType)]];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
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
/*! @brief GET */
- (void)getListWithBar:(NSString *)bar progress:(ProgressBlock)progress success:(SuccessBlock)success failure:(FailBlock)failure {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:bar forKey:@"foo"];
    
    [self doRequest:kHTTPMethodType_GET apiType:kAPIType_GET_List parameters:parameters formData:nil progress:progress success:success failure:failure];
}

/*! @brief POST */
- (void)postListWithBar:(NSString *)bar progress:(ProgressBlock)progress success:(SuccessBlock)success failure:(FailBlock)failure {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:bar forKey:@"foo"];
    
    [self doRequest:kHTTPMethodType_POST apiType:kAPIType_POST_List parameters:parameters formData:nil progress:progress success:success failure:failure];
}

/*! @brief POST_MultiPart */
- (void)uploadImageWithBar:(NSString *)bar formData:(MultiPartFormDataBlock)formData progress:(ProgressBlock)progress success:(SuccessBlock)success failure:(FailBlock)failure {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:bar forKey:@"foo"];
    
    [self doRequest:kHTTPMethodType_POST apiType:kAPIType_POST_List parameters:parameters formData:formData progress:progress success:success failure:failure];
}

/*! @brief PUT */
- (void)putListWithBar:(NSString *)bar success:(SuccessBlock)success failure:(FailBlock)failure {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:bar forKey:@"foo"];
    
    [self doRequest:kHTTPMethodType_PUT apiType:kAPIType_POST_List parameters:parameters formData:nil progress:nil success:success failure:failure];
}

/*! @brief DELETE */
- (void)deleteListWithBar:(NSString *)bar success:(SuccessBlock)success failure:(FailBlock)failure {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:bar forKey:@"foo"];
    
    [self doRequest:kHTTPMethodType_PUT apiType:kAPIType_POST_List parameters:parameters formData:nil progress:nil success:success failure:failure];
}

/*! @brief HEAD */
- (void)headListWithBar:(NSString *)bar success:(SuccessBlock)success failure:(FailBlock)failure {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:bar forKey:@"foo"];
    
    [self doRequest:kHTTPMethodType_PUT apiType:kAPIType_POST_List parameters:parameters formData:nil progress:nil success:success failure:failure];
}

/*! @brief PATCH */
- (void)patchListWithBar:(NSString *)bar success:(SuccessBlock)success failure:(FailBlock)failure {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:bar forKey:@"foo"];
    
    [self doRequest:kHTTPMethodType_PUT apiType:kAPIType_POST_List parameters:parameters formData:nil progress:nil success:success failure:failure];
}

@end
