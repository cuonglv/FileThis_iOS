//
//  FTSession.h
//  FileThis
//
//  Created by Drew on 5/6/12.
//  Copyright (c) 2012 filethis.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

#import "FTAccountSettings.h"
#import "FTInstitution.h"
#import "FTConnection.h"
#import "FTDestination.h"
#import "FTDestinationConnection.h"
#import "FTInstitution.h"

#define DOMAIN_ERROR_CODE                   -1011
#define SERVICE_UNAVAILABLE_STATUS_CODE     503

extern NSString *FTLoginNotification;
extern NSString *FTLoadinFailedNotification;
extern NSString *FTLoggedInNotification;
extern NSString *FTListDestinations;
extern NSString *FTListDestinationConnections;
extern NSString *FTListInstitutions;
extern NSString *FTUpdateInstitutions;
extern NSString *FTListConnections;
extern NSString *FTListQuestionsForConnection;
extern NSString *FTAnswerQuestionsForConnection;
extern NSString *FTDeleteConnection;
extern NSString *FTRefreshConnection;
extern NSString *FTUpdateConnection;
extern NSString *FTCreateUser;
extern NSString *FTGetAccountInfo;
extern NSString *FTPatchAccountInfo;
extern NSString *FTConnectToDestination;
extern NSString *FTPing;
extern NSString *FTMissingCurrentDestination;
extern NSString *FTFixCurrentDestination;
extern NSString *FTCurrentDestinationUpdated;
extern NSString *FTGetProductIdentifiers;

// app-internal notifications
extern NSString *FTGotQuestions;
extern NSString *FTGotConnections;
extern NSString *FTAnsweredQuestion;
extern NSString *FTConnectionDeleted;
extern NSString *FTInstitutionalLogoLoaded;

// exceptions (errorType in json response object)
extern NSString *FTPremiumFeatureException;
extern NSString *FTAccountExpiredException;
extern NSString *FTDestinationNotReadyException;

extern NSString *FTCreateConnectionFailed;

@interface FTSession : AFHTTPClient {
}

@property (strong) NSArray *connections;
@property (nonatomic, readonly) NSArray *institutions;
@property (readonly, strong) NSString *ticket;
@property (nonatomic, strong) FTDestinationConnection *currentDestination;
@property (readonly, nonatomic) NSArray *destinations;
@property (readonly) FTAccountSettings *settings;


//Cuong: debug crash
#ifdef DEBUG_TEST_NULL_CURRENT_DESTINATION_AFTER_REACTIVATING_APP
@property (assign) BOOL app_is_reactivating;
#endif

@property (getter=isValidated) BOOL validated;
@property BOOL loginDisabled;

-(BOOL)deleteNthInstitutionConnection:(int)n;

// TODO: get rid of this stuff
typedef enum {
    FT_CONNECTION_RESOURCE,
    FT_INSTITUTION_RESOURCE,
    FT_CONNECT_TO_INSTITUTION,
    FT_LOGOUT_RESPONSE,
    FT_DELETE_INSTITUTION_CONNECTION
} FTResourceType;

- (BOOL)validateLoginResponse:(id)json;
- (void)logout;
- (void)loadDestinations;
- (void)startup;

-(void)requestConnectionsList;
-(void)cancelRequestConnectionsList;
-(void)requestQuestions;

- (FTConnection *)findConnectionById:(NSInteger)connectionId;
- (FTInstitution *)institutionWithId:(NSInteger)institutionId;

- (NSUInteger)countConnections;
- (FTConnection *)connectionAtIndex:(NSUInteger)index;
- (void)removeConnectionAtIndex:(NSUInteger)index;
- (BOOL)connectionsLoaded;

- (void)ping:(void (^)(void))success;

+ (NSURL *)restURL;
+ (NSURL *)imagesURL;
+ (NSURL *)logosURL;
+ (FTSession *)sharedSession;
+ (NSString *)hostName;
+ (void) setHostName:(NSString *)hostName;

- (NSMutableURLRequest *)requestForOperand:(NSString *)operand withParams:(NSDictionary *)optionalParams;
- (NSMutableURLRequest *)createPostRequest:(NSString *)operand withParameters:(NSDictionary *)optionalParams withXml:(NSString *)xml;

- (void)getAccountPreferences:(void (^)(FTAccountSettings *settings))success;
- (void)getProductIdentifiers;

- (void)getAuthenticationURLForDestination:(NSInteger) destinationId withSuccess:(void (^)(id JSON))success;
- (void)connectToDestination:(NSInteger)destinationId username:(NSString*)username password:(NSString*)password withSuccess:(void (^)(id JSON))success; //Cuong

- (void)verifyDestinationAuthorization:(NSURL *)url
                           withSuccess:(void (^)(NSInteger statusCode))success
                             orFailure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))success;

- (void)login:(NSString *)username withPassword:(NSString *)password
    onSuccess:(void (^)(id JSON))success
    onFailure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

- (void)renewPassword:(NSString *)username
         withPassword:(NSString *)password
            onSuccess:(void (^)(id JSON))success
            onFailure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

- (void)purchase:(SKPaymentTransaction *)transaction
     withSuccess:(void (^)(NSString *result))success
     withFailure:(void (^)(NSError *error))failure;

- (void)presentError:(NSError *)error withTitle:(NSString *)title;

- (void)refreshCurrentDestination;

- (void)saveSettings:(NSDictionary *)update;
- (void)createUser:(NSDictionary *)params onSuccess:(void (^)(id JSON))success onFailure:(void (^)(void))failure;
- (void)handleError:(NSError *)error forOperation:(AFHTTPRequestOperation *)operation withTitle:(NSString *)title;
- (void)handleError:(NSError *)error forResponse:(NSHTTPURLResponse *)response withTitle:(NSString *)title;

- (BOOL)isUsingFTDestination;
+ (void)setTest;
@end
