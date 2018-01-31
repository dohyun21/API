//
//  API.m
//
//
//  Created by kdh on 2018. 1. 31..
//  Copyright © 2018년 Kim Do Hyun. All rights reserved.
//

#import "API.h"

@interface API()
{
    NSMutableDictionary *_endPointDic;
}
@end

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
        _endPointDic = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                         @(kAPIType_GET_List):@"/getList",
                                                                         }];
    }
    return self;
}

#pragma mark - # Public Methods #
+ (id)failResponseStringWithError:(NSError *)error {
    NSData *responseErrorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    
    NSError *jsonError;
    id responseErrorJSON = nil;
    if (responseErrorData) {
        responseErrorJSON = [NSJSONSerialization JSONObjectWithData:responseErrorData options:0 error:&jsonError];
    }
    
    return responseErrorJSON;
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
// URLEncode 함수
-(NSString *)URLEncode:(NSString *)string {
    return [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
//    CFStringRef encoded = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                                                  (__bridge CFStringRef)string,
//                                                                  NULL,
//                                                                  CFSTR(":/?#[]@!$&'()*+,;="),
//                                                                  kCFStringEncodingUTF8);
//    return [NSString stringWithString:(__bridge_transfer NSString *)encoded];
}

#pragma mark - API Request Methods
- (void)doRequestMethodType:(kHTTPMethodType)method apiType:(kAPIType)apiType parameter:(NSMutableDictionary *)parameter formData:(MultiPartFormDataBlock)formData progress:(ProgressBlock)progress success:(SuccessBlock)success fail:(FailBlock)fail
{
    NSString *url = [NSString stringWithFormat:@"%@%@", HOST, _endPointDic[@(apiType)]];
    
    // GET일 경우 URL Encoding 적용
//    NSURLComponents *components = [NSURLComponents componentsWithString:url];
//    NSDictionary *defaultParameters = [self makeRequiredParameters];
//    NSMutableArray *queryItems = [NSMutableArray array];
//    for (NSString *key in defaultParameters) {
//        NSString *_key = [NSString stringWithFormat:@"%@", key];
//        NSString *_value = [NSString stringWithFormat:@"%@", defaultParameters[key]];
//        _value = [self URLEncode:_value];
//
//        [queryItems addObject:[NSURLQueryItem queryItemWithName:_key value:_value]];
//    }
//    components.queryItems = queryItems;
//    url = components.URL.absoluteString;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    switch (apiType) {
        default:
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
    }
    
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

@end
