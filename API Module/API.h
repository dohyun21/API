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
typedef NS_ENUM(NSUInteger, kAPIEndpoint) {
    // ################################################################################################
    // API Examples
    kAPIEndpoint_GET_List,                      // GET
    kAPIEndpoint_POST_List,                     // POST
    kAPIEndpoint_MULTIPART_UploadImage,         // MULTIPART
    kAPIEndpoint_PUT_EditList,                  // PUT
    kAPIEndpoint_DELETE_List,                   // DELETE
    kAPIEndpoint_HEAD_List,                     // HEAD
    kAPIEndpoint_PATCH_List,                    // PATCH
    // ################################################################################################
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

// Response Type
typedef NS_ENUM(NSUInteger, kResponseType) {
    kResponseType_HTTP,
    kResponseType_JSON,
    kResponseType_Image,
    kResponseType_XML,
    kResponseType_PropertyList,
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
- (void)getEndpoint:(kAPIEndpoint)endpoint responseType:(kResponseType)responseType parameters:(NSMutableDictionary *)parameters progress:(ProgressBlock)progress success:(SuccessBlock)success failure:(FailBlock)failure;
- (void)postEndpoint:(kAPIEndpoint)endpoint responseType:(kResponseType)responseType parameters:(NSMutableDictionary *)parameters progress:(ProgressBlock)progress success:(SuccessBlock)success failure:(FailBlock)failure;
- (void)multipartEndpoint:(kAPIEndpoint)endpoint responseType:(kResponseType)responseType formData:(MultiPartFormDataBlock)formData parameters:(NSMutableDictionary *)parameters progress:(ProgressBlock)progress success:(SuccessBlock)success failure:(FailBlock)failure;
- (void)putEndpoint:(kAPIEndpoint)endpoint responseType:(kResponseType)responseType parameters:(NSMutableDictionary *)parameters  success:(SuccessBlock)success failure:(FailBlock)failure;
- (void)deleteEndpoint:(kAPIEndpoint)endpoint responseType:(kResponseType)responseType parameters:(NSMutableDictionary *)parameters success:(SuccessBlock)success failure:(FailBlock)failure;
- (void)headEndpoint:(kAPIEndpoint)endpoint responseType:(kResponseType)responseType parameters:(NSMutableDictionary *)parameters success:(SuccessBlock)success failure:(FailBlock)failure;
- (void)patchEndpoint:(kAPIEndpoint)endpoint responseType:(kResponseType)responseType parameters:(NSMutableDictionary *)parameters success:(SuccessBlock)success failure:(FailBlock)failure;

@end
