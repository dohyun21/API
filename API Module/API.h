//
//  API.h
//
//
//  Created by kdh on 2018. 1. 31..
//  Copyright © 2018년 Kim Do Hyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

#ifdef DEBUG
#define HOST @"http://dev.host.com"
#else
#define HOST @"http://real.host.com"
#endif

// API Type Enum
typedef NS_ENUM(NSUInteger, kAPIType) {
    kAPIType_GET_List,          // 리스트 가져오기
};

// HTTP Method Type
typedef NS_ENUM(NSUInteger, kHTTPMethodType) {
    kHTTPMethodType_GET,
    kHTTPMethodType_POST,
    kHTTPMethodType_POST_MultiPart,
    kHTTPMethodType_PUT,
    kHTTPMethodType_DELETE,
    kHTTPMethodType_HEAD,
    kHTTPMethodType_PATCH,
};

@interface API : NSObject
#pragma mark - Block Response
typedef void(^ProgressBlock)(NSProgress *progress);
typedef void(^SuccessBlock)(NSURLSessionDataTask *task, id responseObject);
typedef void(^FailBlock)(NSURLSessionDataTask *task, NSError *error);
typedef void(^MultiPartFormDataBlock)(id<AFMultipartFormData> data);

#pragma mark - Property List
@property (nonatomic, strong) NSMutableArray *arrayOfAllTasks;                      // 요청중인 Request 정보들
@property (nonatomic, strong) NSURLSessionTask *currentTask;                        // 마지막 Request 정보
@property (nonatomic, strong) NSMutableDictionary *endPointDic;                     // EndPoint 목록

#pragma mark - Public Methods
/*! @brief Binary Data to NSString */
+ (NSString *)binaryDataConversionToString:(NSData *)data;
/*! @brief 에러 Data존재시 NSDictionary, 없을 경우 NSError 반환 */
+ (id)failResponseStringWithError:(NSError *)error;
/*! @brief HTTP Response 상태 코드 예외처리 및 반환 */
+ (NSInteger)checkStatusCodeWithError:(NSURLSessionDataTask *)task;

/*! @brief 최근 요청 취소 */
- (void)cancelCurrentRequest;
/*! @brief 모든 요청 취소 */
- (void)cancelAllRequest;

+ (API *)sharedInstance;

#pragma mark - API Request Methods
- (void)doRequestMethodType:(kHTTPMethodType)method apiType:(kAPIType)apiType parameter:(NSMutableDictionary *)parameter formData:(MultiPartFormDataBlock)formData progress:(ProgressBlock)progress success:(SuccessBlock)success fail:(FailBlock)fail;

/*! @brief Custom Request */
- (void)doRequestMethodType:(kHTTPMethodType)method url:(NSString *)url header:(NSDictionary *)header parameter:(NSMutableDictionary *)parameter formData:(MultiPartFormDataBlock)formData progress:(ProgressBlock)progress success:(SuccessBlock)success fail:(FailBlock)fail;

@end