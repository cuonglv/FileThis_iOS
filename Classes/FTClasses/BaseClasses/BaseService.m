//
//  BaseService.m
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//
#import "BaseService.h"
#import "CacheManager.h"
#import "FTSession.h"
#import "Constants.h"
#import "CommonVar.h"
#import "CommonLayout.h"
#import "MyLog.h"
#import "NetworkReachability.h"
#import "Utils.h"

@implementation BaseService
@synthesize m_receiveData, m_response;

- (id)init {
    self = [super init];
    if (self) {
        self.action = 0;
        self.dictionaryResponse = YES;
        self.timeoutInterval = 30.0;
    }
    
    return self;
}

- (id)initWithAction:(int)action {
    self = [super init];
    if (self) {
        self.action = action;
        self.dictionaryResponse = YES;
    }
    
    return self;
}

- (id)initWithAction:(int)act isDictionaryResponse:(BOOL)isDictionaryResponse {
    self = [super init];
    if (self) {
        self.action = act;
        self.dictionaryResponse = isDictionaryResponse;
    }
    
    return self;
}

- (NSString *)getServerUrl {
    NSString *serverUrl = [[CacheManager getInstance] getServerUrl];
    if (serverUrl != nil && [serverUrl length] > 0) return serverUrl;
    
    return kServer;
}

- (NSString *)getUrlRequest {
    return [NSString stringWithFormat:@"%@%@", [self getServerUrl], [self serviceLink]];
}

- (NSString *)getPostRequest {
    return nil;
}

- (NSString *)serviceLink {
    return nil;
}

- (NSString *)getHttpMethod {
    return @"GET";
}

- (void)initHttpHeader {
    
}

- (NSMutableDictionary *)getHttpHeaders {
    return [[NSMutableDictionary alloc] init];
}

- (id)sendRequestToServer {
    NSError *error;
    id ret = [self sendRequestToServer:&error shouldShowAlert:NO];
    return ret;
}

- (id)sendRequestToServerShouldShowAlert:(BOOL)showAlert {
    NSError *error;
    id ret = [self sendRequestToServer:&error shouldShowAlert:showAlert];
    return ret;
}

- (id)sendRequestToServer:(NSError**)error {
    id ret = [self sendRequestToServer:error shouldShowAlert:NO];
    return ret;
}

- (id)sendRequestToServer:(NSError**)error shouldShowAlert:(BOOL)showAlert {
    self.lastRequestURL = [self getUrlRequest];
    
    self.lastRequestDateTime = [NSDate date];
    
#ifdef ENABLE_NSLOG_REQUEST
    NSLog(@"BaseService - sendRequestToServer: %@", [self.lastRequestURL description]);
#endif
    
    NSURL *URL = [NSURL URLWithString:self.lastRequestURL];
    self.lastRequestBody = [self getPostRequest];
    NSMutableDictionary *httpHeaders = [self getHttpHeaders];
    NSString *httpMethod = [self getHttpMethod];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.timeoutInterval];
    [request setHTTPMethod:httpMethod];
    
    for (id httpHeader in [httpHeaders allKeys]) {
        id httpValue = [httpHeaders valueForKey:httpHeader];
        [request addValue:httpValue  forHTTPHeaderField:httpHeader];
    }
    
    [request setHTTPBody:[self.lastRequestBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    finishLoading = NO;
    m_receiveData=[NSMutableData new];
    
    NSURLResponse *response;
    NSError *errorValue;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&errorValue];
    if (error) {
        *error = errorValue;
    }
    
    self.responseStatusCode = -1;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        self.responseStatusCode = [(NSHTTPURLResponse*)response statusCode];
    }
    
    self.m_response = (NSHTTPURLResponse *)response;
    
    [MyLog writeLogWithService:self responseData:responseData];
    
    if (self.dictionaryResponse) {
        if ([responseData length] == 0) {
            if (showAlert) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *msg = nil;
                    if (errorValue) {
                        msg = [errorValue localizedDescription];
                    }
                    if (msg.length > 0) {
                        [CommonLayout showAlertMessageWithTitle:@"Error" content:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitle:nil];
                    }
                });
            }
            return nil;
        }
        
        NSString *jsonResponse = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        if (self.responseStatusCode != 200 && self.responseStatusCode != 201) {
            self.errorMessage = jsonResponse;
        }
        if (self.responseStatusCode == SERVICE_UNAVAILABLE_STATUS_CODE) {
            self.errorMessage = NSLocalizedString(@"ID_COMMUNICATION_COMMON_ERROR", @"");
        }
        
        if (jsonResponse == nil) {
            jsonResponse = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
            responseData = [jsonResponse dataUsingEncoding:NSUTF8StringEncoding];
        }
        
#ifdef ENABLE_NSLOG_REQUEST
        NSString *responseDesc;
        if ([jsonResponse length] > 10000)
            responseDesc = [jsonResponse substringToIndex:10000];
        else
            responseDesc = jsonResponse;
        
        NSLog(@"BaseService - Response %.0fs(%@): %@", -[self.lastRequestDateTime timeIntervalSinceNow],self.lastRequestURL, responseDesc);
#endif
        
        if ( (self.responseStatusCode > 0) && (self.errorMessage.length > 0) ) {
            if (error) {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.errorMessage forKey:NSLocalizedDescriptionKey];
                NSError *reError = [[NSError alloc] initWithDomain:AFNetworkingErrorDomain code:self.responseStatusCode userInfo:userInfo];
                *error = reError;
            }
        }
        
        if (showAlert && self.errorMessage.length > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [CommonLayout showAlertMessageWithTitle:nil content:self.errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitle:nil];
            });
        }
        
        id ret = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
        return ret;
    }
    
    if (self.responseStatusCode == SERVICE_UNAVAILABLE_STATUS_CODE) {
        self.errorMessage = NSLocalizedString(@"ID_COMMUNICATION_COMMON_ERROR", @"");
    }
    
    if ( (self.responseStatusCode > 0) && (self.errorMessage.length > 0) ) {
        if (error) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.errorMessage forKey:NSLocalizedDescriptionKey];
            NSError *reError = [[NSError alloc] initWithDomain:AFNetworkingErrorDomain code:self.responseStatusCode userInfo:userInfo];
            *error = reError;
        }
    }
    
    NSLog(@"BaseService - Response %.0fs(%@): data length %i", -[self.lastRequestDateTime timeIntervalSinceNow],self.lastRequestURL, [responseData length]);
    
    if (showAlert && self.errorMessage.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [CommonLayout showAlertMessageWithTitle:nil content:self.errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitle:nil];
        });
    }
    
    return responseData;
}

- (NSString *)doStatusCode401 {
    return nil;
}

#pragma mark - nsurlconnectiondelegate
/*- (BOOL)connection:(NSURLConnection *)conn canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)conn didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
	{
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
	}
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.m_response = (NSHTTPURLResponse *)response;
    NSLog(@"FileThis - statusCode = %d", [self.m_response statusCode]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.m_receiveData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    err = error;
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    finishLoading = YES;
    CFRunLoopStop(CFRunLoopGetCurrent());
}*/

@end
