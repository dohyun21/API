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
    kAPIType_POST_List,         // 리스트 추가하기
    kAPIType_POST_UploadImage,  // 이미지 업로드
    kAPIType_PUT_EditList,      // 리스트 수정하기
    kAPIType_DELETE_List,       // 리스트 삭제하기
    kAPIType_HEAD_List,         // HEAD
    kAPIType_PATCH_List,        // PATCH
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
/*! @brief GET */
- (void)getListWithBar:(NSString *)bar progress:(ProgressBlock)progress success:(SuccessBlock)success failure:(FailBlock)failure;
/*! @brief POST */
- (void)postListWithBar:(NSString *)bar progress:(ProgressBlock)progress success:(SuccessBlock)success failure:(FailBlock)failure;
/*! @brief POST_MultiPart */
- (void)uploadImageWithBar:(NSString *)bar formData:(MultiPartFormDataBlock)formData progress:(ProgressBlock)progress success:(SuccessBlock)success failure:(FailBlock)failure;
/*! @brief PUT */
- (void)putListWithBar:(NSString *)bar success:(SuccessBlock)success failure:(FailBlock)failure;
/*! @brief DELETE */
- (void)deleteListWithBar:(NSString *)bar success:(SuccessBlock)success failure:(FailBlock)failure;
/*! @brief HEAD */
- (void)headListWithBar:(NSString *)bar success:(SuccessBlock)success failure:(FailBlock)failure;
/*! @brief PATCH */
- (void)patchListWithBar:(NSString *)bar success:(SuccessBlock)success failure:(FailBlock)failure;

@end
