//
//  BaseService.h
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//

#import "BaseObject.h"
#import "Constants.h"
#import "NSString+URLEncoding.h"

@interface BaseService : BaseObject
{
    NSMutableData *m_receiveData;
    NSHTTPURLResponse *m_response;
    NSError *err;
    BOOL finishLoading;
}

@property (nonatomic, strong) NSMutableData *m_receiveData;
@property (nonatomic, strong) NSHTTPURLResponse *m_response;
@property (nonatomic, assign) int action;
@property (nonatomic, assign) BOOL dictionaryResponse;
@property (assign) NSInteger responseStatusCode;
@property (assign) int timeoutInterval;
@property (nonatomic, copy) NSString *errorMessage;

@property (nonatomic, copy) NSString *lastRequestURL, *lastRequestBody;
@property (nonatomic, copy) NSDate *lastRequestDateTime;

- (id)initWithAction:(int)action;
- (id)initWithAction:(int)action isDictionaryResponse:(BOOL)isDictionaryResponse;
- (NSString *)getHttpMethod;
- (NSString *)getServerUrl;
- (NSString *)getUrlRequest;
- (NSString *)getPostRequest;
- (NSMutableDictionary *)getHttpHeaders;
- (NSString *)serviceLink;
- (id)sendRequestToServer;
- (id)sendRequestToServerShouldShowAlert:(BOOL)showAlert;
- (id)sendRequestToServer:(NSError**)error;
- (id)sendRequestToServer:(NSError**)error shouldShowAlert:(BOOL)showAlert;

@end
