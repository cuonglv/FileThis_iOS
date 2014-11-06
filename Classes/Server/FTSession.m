//
//  FTSession.m
//  FileThis
//
//  Created by Drew on 5/6/12.
//  Copyright (c) 2012 filethis.com. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "AFJSONRequestOperation.h"

#import "AppleStoreObserver.h"

#import "FTAccountSettings.h"
#import "FTMobileAppDelegate.h"
#import "FTSession.h"
#import "FTDestination.h"
#import "FTConnection.h"
#import "FTQuestion.h"
#import "FTInstitution.h"
#import "FTRequest.h"
#import "MF_Base64Additions.h"
#import "UIKitExtensions.h"
#import "ServerPickerViewController.h"

#import "CommonVar.h"
#import "OrderedDictionary.h"
#import "FTMobileAppDelegate.h"

// operands for talking to server
NSString *FTLoginNotification = @"weblogin";
NSString *FTRenewPasswordNotification = @"webnewpassword";
NSString *FTLoadinFailedNotification = @"loadinnoworkie";
NSString *FTLoggedInNotification = @"loggedin";
NSString *FTLogout = @"userlogout";
NSString *FTListInstitutions = @"institutionlist";
NSString *FTUpdateInstitutions = @"updateinstitution";
NSString *FTDeleteConnection = @"conndelete";
NSString *FTListConnections = @"connlist";
NSString *FTRefreshConnection = @"connconnect";
NSString *FTUpdateConnection = @"connupdate";
NSString *FTAnswerQuestionsForConnection = @"questionanswer";
NSString *FTListQuestionsForConnection = @"questionlist";
NSString *FTListDestinations = @"destinationlist";
NSString *FTCurrentDestinationUpdated = @"dstconnlist";
NSString *FTCreateUser = @"webnewaccount";
NSString *FTGetAccountInfo = @"accountinfo";
NSString *FTPatchAccountInfo = @"accountupdate";
NSString *FTGetProductIdentifiers = @"billingappleproducts";
NSString *FTConnectToDestination = @"connecttodestination";
NSString *FTPing=@"ping";
NSString *FTPurchase = @"billingapplepurchase";


// app-internal notifications
NSString *FTGotQuestions = @"gotquestions";
NSString *FTGotConnections = @"gotconnections";
NSString *FTAnsweredQuestion = @"answerquestion";
NSString *FTConnectionDeleted = @"connectiondeleted";

NSString *FTInstitutionalLogoLoaded = @"institutionalLogoLoaded";
NSString *FTMissingCurrentDestination = @"missingcurrentdestination";
NSString *FTFixCurrentDestination = @"fixcurrentdestination";
NSString *FTCreateConnectionFailed = @"createdconnectionfailed";

// Exceptions
NSString *FT_ExpiredTicketExceptionString = @"com.filethis.common.exception.TicketExpiredException";
NSString *FTPremiumFeatureException = @"com.filethis.common.exception.PremiumFeatureException";
NSString *FTAccountExpiredException = @"com.filethis.common.exception.AccountHasExpiredException";
NSString *FTDestinationNotReadyException = @"com.filethis.common.exception.DestinationNotReadyException";

@interface FTSession () {
    NSMutableArray *_connections;
}
@property (strong) NSDictionary *institutionalLogoMap;
@property NSArray *destinationConnections;
@property NSArray *destinations;

@property (readonly, getter = isAuthenticated) BOOL authenticated;
@property (nonatomic, strong) ProcessConnectionsOperation *connectionsResponseProcessor;
@property (nonatomic, strong) AFJSONRequestOperation *connectionsRequestOperation;
@property (nonatomic,strong) NSOperationQueue *processingQueue;
@property (nonatomic, strong) NSArray *institutions;
@property (strong,nonatomic) NSDictionary *products;
@property (strong,nonatomic) NSString *lastErrorDescription;
@property (strong, nonatomic) FTAccountSettings *settings;
@property time_t lastErrorTime;

// redefine public properties


@end

// keys into InstitutionConnection
NSString *FT_INSTITUTION_ID_KEY = @"institutionId";
NSString *FT_INSTITUTION_CONNECTION_ID_KEY = @"id";

// Institution keys
NSString *FT_INSTITUTION_LOGO_PATH_KEY = @"logoPath";

double REFRESH_DELAY_IN_SECONDS = 10.0;

@implementation FTSession


static NSURL *_secureURL;
+ (NSURL *)secureURL {
    if (_secureURL == nil) {
        NSString *URLString = [NSString stringWithFormat:@"https://%@/fetch", [self hostName]];
        _secureURL = [[NSURL alloc] initWithString:URLString];
    }
    return _secureURL;
}

static NSURL *_staticURL;
+ (NSURL *)staticURL {
    if (_staticURL == nil) {
        NSString *URLString = [NSString stringWithFormat:@"https://%@/fetch", [self hostName]];
        _staticURL = [[NSURL alloc] initWithString:URLString];
    }
    return _staticURL;
}

static NSURL *_restURL;
+ (NSURL *)restURL {
    if (_restURL == nil) {
        _restURL = [[NSURL alloc] initWithString:@"/ftapi/ftapi" relativeToURL:[self secureURL]];
    }
    return _restURL;
}

static NSURL *_imagesURL = NULL;
+ (NSURL *)imagesURL {
    if (_imagesURL == nil)
        _imagesURL = [[NSURL alloc] initWithString:@"/static/" relativeToURL:[self staticURL]];

    return _imagesURL;
}

static NSURL *_logosURL;
+ (NSURL *)logosURL {
    if (_logosURL == nil) {
        float scale = 2; // see explanation below
        float dpi = 72;
        // NOTE: logos are stored in high-res for Retina displays
        // by resolution: 326 for iPhone Retina display or 264 for
        // iPad Retina display dpi.
        // If high res images don't scale down nicely on non-Retina displays,
        // we could also have 163 and 132 dpi images.
        // For now, we just use high res and hard-code scale to 2.
        //        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        //            scale = [[UIScreen mainScreen] scale];
        //        } else {
        //            NSLog(@"UIDevice doesn't respond to scale");
        //        }
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//            dpi = 132 * scale;
//        } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            dpi = 163 * scale;
//        }
        NSString *relativePath = [NSString stringWithFormat:@"/static/logos/%.0f/", dpi];
        _logosURL = [[NSURL alloc] initWithString:relativePath relativeToURL:[self secureURL]];
    }
    return _logosURL;
}

static FTSession *_sharedSession;
+(FTSession *)sharedSession {
    if (_sharedSession == nil)
        _sharedSession = [[FTSession alloc] init];
    return _sharedSession;
}

static NSString *_hostName;
+ (void)setHostName:(NSString *)newHostName {
    _hostName = newHostName;
    [[NSUserDefaults standardUserDefaults] setObject:newHostName forKey:@"HOSTNAME"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _sharedSession = nil;
    _staticURL = nil;
    _logosURL = nil;
    _secureURL = nil;
    _restURL = nil;
    _imagesURL = nil;
}

//Loc test
BOOL test = NO;
+ (void)setTest {
    test = YES;
}
//---

+ (NSString *)hostName
{
    //Loc test
    if (test) {
        //return @"astaging.filethis.com";
    }
    //---
    if (!_hostName) {
#ifdef DEBUG
        _hostName = [[NSUserDefaults standardUserDefaults] objectForKey:@"HOSTNAME"];
#endif
        if (!_hostName) {
            NSString *defaultHostname = [ServerPickerViewController configurations][0];
            [self setHostName:defaultHostname];
        }
    }
    return _hostName;
}

- (id) init
{
    if ((self = [super initWithBaseURL:[[self class] secureURL]])) {
        
        //Cuong: debug crash
#ifdef DEBUG_TEST_NULL_CURRENT_DESTINATION_AFTER_REACTIVATING_APP
        self.app_is_reactivating = NO;
#endif
        
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInstitutions:) name:FTUpdateInstitutions object:nil];
        
        self.processingQueue = [[NSOperationQueue alloc] init];
        [self.processingQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
        self.processingQueue.name = @"FileThisProcessing";
        
        // user-agent needs to have "FileThis Mobile" to disable timeouts
        NSString *userAgent = [self defaultValueForHeader:@"User-Agent"];
        userAgent = [NSString stringWithFormat:@"%@, FileThis Mobile", userAgent];
        [self setDefaultHeader:@"User-Agent" value:userAgent];
#ifdef ENABLE_NSLOG_REQUEST
        NSLog(@"user-agent=%@", [self defaultValueForHeader:@"User-Agent"]);
#endif
    }
    
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.processingQueue cancelAllOperations];
}


//- (void)startup
//{
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if ([defaults boolForKey:@"autologin"]) {
//        NSString *username = [defaults objectForKey:@"loginName"];
//        NSString *password = [defaults objectForKey:@"password"];
//        NSString *ticket = [defaults objectForKey:@"ticket"];
//        if (username.length > 0 && password.length > 0) {
//            NSString  *params = [NSString stringWithFormat:@"&email=%@&password=%@",username, password];
//            FTRequest *req = [[FTRequest alloc] initWithTicket:nil withVerb:FTLoginNotification withParameters:params];
//            NSAssert(NO, @"old code");
//            [req setReceiver:[FTSession sharedSession] withAction:@selector(validateLoginResponse:)];
//            [req start];
//        } else if (ticket != nil) {
//            // TODO: validate ticket by pinging server with ticket to see if it's expired
//        }
//    }
//}
//

#pragma mark Properties
- (NSString *)ticket {
    return [CommonVar ticket];
}

- (BOOL)isAuthenticated
{
    return self.ticket != nil;
}

-(NSArray *)connections {
    @synchronized(self) {
        return _connections;
    }
}

-(void)setConnections:(NSArray *)connections {
    @synchronized(self) {
        _connections = [connections mutableCopy];
    }
    if (connections) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FTListConnections object:NULL userInfo:NULL];
    }
}

- (BOOL)validateLoginResponse:(id)json
{
#ifdef ENABLE_NSLOG_REQUEST
    NSLog(@"received data %@", json);
#endif
    NSString *result = json[@"result"];
    BOOL authenticated = [result caseInsensitiveCompare:@"ok"] == NSOrderedSame ? YES : NO;
    if (authenticated) {
        //        NSLog(@"logged in as %@", self.userName);
        NSString *nextString = json[@"next"];
        NSURL *nextURL = [NSURL URLWithString:nextString];
        NSString *query = [nextURL query];
        NSString *ticket = [self getValueFromQueryString:query withField:@"ticket"];
        [CommonVar setTicket:ticket];
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        [self setTicket:ticket];
//        [defaults setObject:ticket forKey:@"ticket"];
//        [defaults synchronize];
        self.validated = YES;
//        [CommonVar setTicket:ticket];
//        [CommonVar savePlist];
    }
    return authenticated;
}

- (BOOL)pickDestinationIfRequired:(UIViewController *)source {
    if ([FTSession sharedSession].currentDestination == nil) {
        UIStoryboard *storyboard = [UIApplication sharedApplication].delegate.window.rootViewController.storyboard;
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"destinationPicker"];
        vc.navigationItem.hidesBackButton = YES;

        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//        [source.navigationController pushViewController:vc animated:YES];
        [source presentViewController:vc animated:YES completion:nil];
        return YES;
    } else {
        return NO;
    }
}

- (void)refreshCurrentDestination
{
    [(FTMobileAppDelegate*)[UIApplication sharedApplication].delegate clearData];   //Cuong
    AFHTTPRequestOperation *op = [self getCurrentDestinationOperation];
    [self enqueueAuthenticatedOperation:op];
}

- (AFJSONRequestOperation *)getDestinationsOperation:(void (^)(NSArray *destinations))success
{
    NSMutableURLRequest *request = [self requestForOperand:FTListDestinations withParams:nil];
    AFJSONRequestOperation *op = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *jsons = JSON[@"destinations"];
        NSArray *destinations = [jsons sortedArrayUsingComparator:
                ^NSComparisonResult(NSDictionary *dest1, NSDictionary *dest2) {
                    int i1 = [[dest1 objectForKey:@"ordinal"] integerValue];
                    int i2 = [[dest2 objectForKey:@"ordinal"] integerValue];
                    if (i1 > i2)
                        return NSOrderedDescending;
                    return (i1 < i2) ? NSOrderedAscending : NSOrderedSame;
                }];
        success(destinations);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (![operation isCancelled])
            [self handleError:error withTitle:@"" withResponse:operation.response];
    }];
    
    return op;
}

- (AFJSONRequestOperation *)getDestinations
{
    AFJSONRequestOperation *operation = [self getDestinationsOperation:^(NSArray *json) {

#ifdef ENABLE_NSLOG_REQUEST
        NSLog(@"got %d destinations: %@", [json count], [json description]);
#endif

        NSMutableArray *destinations = [NSMutableArray arrayWithCapacity:json.count];
        for (NSDictionary *d in json)
        {
//            if ([[d objectForKey:@"type"] isEqualToString:@"conn"]) {     //Cuong
                FTDestination *destination = [[FTDestination alloc] initWithDictionary:d];
                [destinations addObject:destination];
//            }
        }
        self.destinations = [NSArray arrayWithArray: destinations];
        [[NSNotificationCenter defaultCenter] postNotificationName:FTListDestinations object:destinations userInfo:NULL];
    }];
    return operation;
}

// stuff that doesn't have to be done immediately upon
// setting the ticket.
- (void)delayedInitialization
{
    [[AppleStoreObserver sharedObserver] login];
    [self getAccountPreferences:nil];
}

- (void)reset {
    [self.connectionsRequestOperation cancel];
    [self.connectionsResponseProcessor cancel];
    [self.operationQueue cancelAllOperations];
    [self.processingQueue cancelAllOperations];
    self.connectionsRequestOperation = nil;
    self.connectionsResponseProcessor = nil;
    self.processingQueue = nil;

    self.validated = NO;
    [CommonVar setTicket:nil];
//    self.ticket = nil;
    self.connections = nil;
    self.currentDestination = nil;
        
        // DEBUG - debug institutions not loaded
    self.institutions = nil;
    
    // discard old Session to avoid problems with old operations remaining in queue
    _sharedSession = [[FTSession alloc] init];
}

-(void)logout {
    FTRequest *logoutRequest = [[FTRequest alloc] initWithTicket:self.ticket withVerb:FTLogout withParameters:nil];
    [logoutRequest setReceiver:self withAction:@selector(loggedOut:)];
    [self reset];
}

- (void)loggedOut:(id)sender{
#ifdef ENABLE_NSLOG_REQUEST
    NSLog(@"logged out ack");
#endif
}

- (BOOL)deleteNthInstitutionConnection:(NSInteger) n {
    FTConnection *connection = nil;
    @synchronized (self) {
        //try catch to avoid out of range exception
        @try {
            if ( (n >= 0) && (n < self.connections.count) )
                connection = [self.connections objectAtIndex:n];
        } @catch (NSException *exception) {
        }
    }
    
    [connection destroy];
    return NO;
}

-(void)updateInstitutions:(NSNotification *)notification {
    NSArray *institutions = notification.object;
    //NSAssert([institutions count] > 0, @"non-empty list");
    
    /*if (self.institutions) {
        NSAssert([self.institutions count] == [institutions count], @"cannot merge disjoint institutions");
        //merge
    } else {
        self.institutions = [institutions copy];
    }*/
    
    self.institutions = [institutions copy];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FTListInstitutions object:self.institutions];
}

#ifdef DEBUG
- (void)debugReceipt:(NSString *)receipt
{
    NSURL *url = [[NSURL alloc] initWithString:@"https://sandbox.itunes.apple.com"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [httpClient setDefaultHeader:@"Accept" value:@"application/json"];
    [httpClient setDefaultHeader:@"Accept" value:@"text/plain"];
    NSDictionary *params = @{@"password" : @"c090b73a77774b87b0a46f1a9c009bed",
                             @"receipt-data" : receipt};
    NSMutableURLRequest *req = [httpClient requestWithMethod:@"POST" path:@"/verifyReceipt" parameters:params];
    NSLog(@"request header=%@", [req allHTTPHeaderFields]);
    
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:req
                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                    NSLog(@"success: %@", JSON);
                }
                failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                    NSLog(@"failure: %@", JSON);
                    NSString *body = [[NSString alloc] initWithData:[request HTTPBody] encoding:4];
                    NSLog(@"HTTPBody:%@", body);
                }];
    [self enqueueHTTPRequestOperation:op];
}
#endif

- (void)logRequest:(NSURLRequest *)request withResponse:(NSHTTPURLResponse *)response withJSON:(id)json withMessage:(NSString *)message withError:(NSError *)error {
#ifdef ENABLE_NSLOG_REQUEST
    if (error)
        NSLog(@"%@ request=%@, json=%@, error=%@", message, [[request URL] parameterString], json, error);
    else
        NSLog(@"%@ request=%@, json=%@", message, [[request URL] parameterString], json);
#endif
}


/*
    billingapplepurchase

    The request should have the form:
    https://integration.filethis.com/ftapi/ftapi?op=billingapplepurchase&ticket=<ticket>&receipt=<receipt>

    where <receipt> is the string you get back from the Apple store. I assume that you'll URL-encode this, if necessary.

    The response is JSON of the form:
        { "result": "<code>" }

    where <code> is one of:

    success - The receipt was found to be valid, and the FileThis account's billing information was successfully updated.
    invalid_receipt - The receipt was found to be invalid. You shouldn't ever see this response, but if you do, maybe there's something you could tell the user.
    failure - Something went wrong, either in the server's interaction with the Apple store when validating the receipt, or in the server code itself. You'll need to retry later.
*/

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)purchase:(SKPaymentTransaction *)transaction
     withSuccess:(void (^)(NSString *result))success
     withFailure:(void (^)(NSError *error))failure
{
    NSString *receipt = [transaction.transactionReceipt base64String];
    NSDictionary *params = @{@"receipt" : receipt};
    NSMutableURLRequest *req = [self requestForOperand:FTPurchase withParams:params];
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:req
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            [self logRequest:request withResponse:response withJSON:JSON withMessage:@"success" withError:nil];
            success(JSON[@"result"]);
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            [self logRequest:request withResponse:response withJSON:JSON
                 withMessage:@"purchase request failed" withError:error];
            [self handleError:error withTitle:@"Cannot Save Purchase" withResponse:response];
        }];
    [self enqueueAuthenticatedOperation:operation];    
}
#pragma GCC diagnostic pop

-(FTInstitution *)institutionWithId:(NSInteger)institutionId {
    for (FTInstitution *institution in self.institutions) {
        if (institutionId == institution.institutionId)
            return institution;
    }
    return nil;
}

#pragma mark ### NSURLConnectionData delegate methods

// Parse the individual parameters
// parameters = @"hello=world&foo=bar";
- (id) getValueFromQueryString:(NSString *)query withField:(NSString *) fieldName {
    NSArray *arrParameters = [query componentsSeparatedByString:@"&"];
    for (int i = 0; i < [arrParameters count]; i++) {
        NSArray *arrKeyValue = [arrParameters[i] componentsSeparatedByString:@"="];
        if ([arrKeyValue count] >= 2) {
            NSString *keyName = arrKeyValue[0];
            if ([keyName isEqualToString:fieldName])
                return arrKeyValue[1];
        }
    }
    return NULL;
}

- (NSString *) getOperandFromFileThisRequest:(NSURLRequest *)request {
    NSURL *url = [request URL];
    return [self getValueFromQueryString:[url query] withField:@"op"];
}

#pragma  mark -
#pragma  mark FTConnection handling

- (BOOL)resetConnectionsRequest {
    // don't reset unless finished
    if (self.validated && self.connectionsResponseProcessor != nil && ![self.connectionsResponseProcessor isFinished]) {
        fprintf(stderr, "process connections %lu in progress\n", (unsigned long)self.connectionsResponseProcessor.sequenceNumber);
        return NO;
    }
    
    ProcessConnectionsOperation *connectionsResponseProcessor = [[ProcessConnectionsOperation alloc] init];
    fprintf(stderr, "new process connections %lu\n", (unsigned long)connectionsResponseProcessor.sequenceNumber);
    AFJSONRequestOperation *connectionsRequestOperation = [self getConnections:^(id JSON) {
        connectionsResponseProcessor.json = JSON;
        NSAssert(JSON[@"connections"], @"valid connections result");
        connectionsResponseProcessor.oldConnections = self.connections;
    }];
    [connectionsResponseProcessor addDependency:connectionsRequestOperation];

    self.connectionsResponseProcessor = connectionsResponseProcessor;
    self.connectionsRequestOperation = connectionsRequestOperation;
    return YES;
}

// start downloading connections
- (void)requestConnectionsList
{
    if (self.processingQueue && self.connectionsRequestOperation && self.connectionsResponseProcessor) {
        if ([self resetConnectionsRequest]) {
            [self enqueueAuthenticatedOperation:self.connectionsRequestOperation];
            [self enqueueProcessingOperation:self.connectionsResponseProcessor];
        }
    }
}

- (void)cancelRequestConnectionsList {
    [self.connectionsRequestOperation cancel];
    [self.connectionsResponseProcessor cancel];
    self.connectionsRequestOperation = nil;
    self.connectionsResponseProcessor = nil;
    self.validated = NO;
    [self resetConnectionsRequest];
}

#pragma mark - Account Settings

/*
 
 https://staging.filethis.com/ftapi/ftapi?op=connecttodestination&flex=true&json=true&compact=true&id=4&browseable=false&ticket=eLVoEBtNJ6Gh9eB1YuOIP05bJep	200	GET	staging.filethis.com	/ftapi/ftapi?op=connecttodestination&flex=true&json=true&compact=true&id=4&browseable=false&ticket=eLVoEBtNJ6Gh9eB1YuOIP05bJep	 1237 ms	1.27 KB	Complete	
 

{
 "returnValue":"https://www.dropbox.com:443/1/oauth/authorize?oauth_token=54dxhm9bskvv1wb&oauth_callback=https%3A%2F%2Fstaging.filethis.com%2Fftapi%2Fftapi%3Fop%3Ddropbox%26aid%3D407%26ticket%3DeLVoEBtNJ6Gh9eB1YuOIP05bJep&locale=en"
}
 
 */

- (void)connectToDestination:(FTDestination *)destination {
    
    [self getAuthenticationURLForDestination:destination.destinationId withSuccess:^(id authurl) {
#ifdef ENABLE_NSLOG_REQUEST
        NSLog(@"connection to %@", authurl);
#endif
    }];
    
//{"returnValue":"https://www.dropbox.com:443/1/oauth/authorize?oauth_token=54dxhm9bskvv1wb&oauth_callback=https%3A%2F%2Fstaging.filethis.com%2Fftapi%2Fftapi%3Fop%3Ddropbox%26aid%3D407%26ticket%3DeLVoEBtNJ6Gh9eB1YuOIP05bJep&locale=en"}
    
}

#pragma  mark -
#pragma  mark FTConnection handling
- (FTConnection *)findConnectionById:(NSInteger)connectionId {
    __block FTConnection *result;
    [self.connections enumerateObjectsUsingBlock:^(FTConnection *connection, NSUInteger idx, BOOL *stop) {
        if (connection.connectionId == connectionId)
        {
            result = connection;
            *stop = YES;
        }
    }];
    
    return result;
}

- (NSUInteger)countConnections {
    return self.connections.count;
}

- (FTConnection *)connectionAtIndex:(NSUInteger)index {
    if (self.connections && [self.connections count] > 0)
        return [self.connections objectAtIndex:index];
    return nil;
}

- (void)removeConnectionAtIndex:(NSUInteger)index {
    [self.connectionsResponseProcessor cancel];
    [_connections removeObjectAtIndex:index];
    [self requestConnectionsList];
}

- (BOOL)connectionsLoaded
{
    return self.connections != nil;
}

#pragma  mark -
#pragma  mark FTQuestion handling

// start downloading institutions

- (NSArray *)parseQuestionsFromDictionary:(NSDictionary *)questionsDictionary {
    // move "data" keypair tuples up into question object
    NSString *dataString = questionsDictionary[@"data"];
    if (dataString != nil) {
        NSMutableArray *newQuestions = [@[] mutableCopy];
        NSError *error = nil;
        NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (json == nil) {
#ifdef ENABLE_NSLOG_REQUEST
            NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@ parsing JSON string:%@", error, s);
#endif
        }
        
        NSMutableDictionary *changingValues = [NSMutableDictionary dictionaryWithDictionary:questionsDictionary];
        [changingValues removeObjectForKey:@"data"];
        [changingValues addEntriesFromDictionary:json];
        NSArray *questions = [changingValues objectForKey:@"questions"];
        [changingValues removeObjectForKey:@"questions"];
        NSDictionary *commonValues = [NSDictionary dictionaryWithDictionary:changingValues];
        
        for (NSDictionary *questionValues in questions) {
            NSMutableDictionary *questionableValues = [commonValues mutableCopy];
            [questionableValues addEntriesFromDictionary:questionValues];
            FTQuestion *question = [[FTQuestion alloc] initWithDictionary:questionableValues];
            [newQuestions addObject:question];
        }
        
        if (newQuestions.count > 0) {
            return newQuestions;
        }
        
        //+++++
        //Handle the case when there is no questions but there is notice message
        FTQuestion *ques = [[FTQuestion alloc] initWithDictionary:json];
        [ques addInformationWithDictionary:questionsDictionary];
        ques.isNoticeMessage = YES;
        return @[ques];
        //-----
    }
    
    return @[[[FTQuestion alloc] initWithDictionary:questionsDictionary]];
}

- (BOOL)questionExistsById:(NSInteger)questionId {
    BOOL exists = NO;
    for (FTConnection *connection in self.connections) {
        for (FTQuestion *question in connection.questions) {
            exists = (question.uniqueId == questionId);
            if (exists)
                break;
        }
        if (exists)
            break;
    }
    return  exists;
}

- (void)processQuestions:(NSArray *)questionsData {
    /*
     Process questions list, discarding questions for non-existent connections.
     Only forward valid questions.
     Note: we don't add the questions to our list of connections because of thread-safety concerns.
     Maybe we should... For now, post notification which will be process on main runloop.
     */
    
#ifdef DEBUG_SET_USER_ACTION_REQUIRED_FOR_1ST_CREDENTIALS_QUESTION
    BOOL isFisrtCredentialsQuestion = YES;
#endif
    NSMutableArray *relevantQuestions = [NSMutableArray arrayWithCapacity:questionsData.count];
    int numMissing = 0;
    int numExisting = 0;
    for (NSDictionary *questionDictionary in questionsData) {
        NSInteger questionId = [questionDictionary[@"id"] integerValue];
        if ([self questionExistsById:questionId]) {
            // skip it - question already is loaded
            numExisting++;
        } else {
            NSInteger connectionId = [questionDictionary[@"connectionId"] integerValue];
            FTConnection *connection = [self findConnectionById:connectionId];
            if (connection != nil) {
                [relevantQuestions addObjectsFromArray:[self parseQuestionsFromDictionary:questionDictionary]];
                // [manhnn] Put questions into connections
                for (FTQuestion *question in relevantQuestions) {
                    FTConnection *conn = [self findConnectionById:question.connectionId];
                    if (conn && ![conn.questions containsObject:question]) {
                        [conn addQuestion:question];
#ifdef DEBUG_SET_USER_ACTION_REQUIRED_FOR_1ST_CREDENTIALS_QUESTION
                        if (isFisrtCredentialsQuestion) {
                            if ([question isCredentials]) {
                                question.type = @"user_action_required";
                                question.key = nil;
                                question.label = @"Please log into your account directly and respond to the question you are being asked there";
                                isFisrtCredentialsQuestion = NO;
                            }
                        }
#endif
                    }
                }
            } else {
                // skip it - connection no longer around
                numMissing++;
            }
        }
    }
#ifdef ENABLE_NSLOG_REQUEST
    NSUInteger numQuestionsAdded = [relevantQuestions count];
    NSLog(@"%d questions active and added, %d skipped, %d missing connections", numQuestionsAdded, numExisting, numMissing);
#endif
    
    // [manhnn] Cannot post FTGotQuestions because the ConnectionViewController is not loaded yet.
    // if there are questions, let observers know about them
    //if (numQuestionsAdded != 0)
        //[[NSNotificationCenter defaultCenter] postNotificationName:FTGotQuestions object:relevantQuestions userInfo:nil];
}

- (void)requestQuestions {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableURLRequest *req = [self requestForOperand:FTListQuestionsForConnection withParams:nil];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation
                JSONRequestOperationWithRequest:req
                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [self processQuestions:JSON[@"questions"]];
                        });
                    }
                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                        [self handleError:error withTitle:@"" withResponse:response];
                    }];
        [self enqueueAuthenticatedOperation:operation];
    });
}

// https://staging.filethis.com/ftapi/ftapi?jsonp=jQuery16204539361447095871_1353966856904&first=f&last=l&email=drewmwilson%40mailinator.com&password=brian6&create-password-repeat=brian6&terms-of-service=on&op=webnewaccount&type=conn&_=1353966940108

/*
 
 https://staging.filethis.com/ftapi/ftapi?jsonp=jQuery16204539361447095871_1353966856904&first=f&last=l&email=drewmwilson%40mailinator.com&password=brian6&create-password-repeat=brian6&terms-of-service=on&op=webnewaccount&type=conn&_=1353966940108	200	GET	staging.filethis.com	/ftapi/ftapi?jsonp=jQuery16204539361447095871_1353966856904&first=f&last=l&email=drewmwilson%40mailinator.com&password=brian6&create-password-repeat=brian6&terms-of-service=on&op=webnewaccount&type=conn&_=1353966940108	 608 ms	1.51 KB	Complete	
 
 
 jsonp	jQuery16204539361447095871_1353966856904
 first	f
 last	l
 email	drewmwilson@mailinator.com
 password	brian6
 create-password-repeat	brian6
 terms-of-service	on
 op	webnewaccount
 type	conn
 _	1353966940108
 
 
 jQuery16204539361447095871_1353966856904({
 "result":"ERROR",
 "error":
 {
 "type":"AccountExistsException",
 "text":"An account with email address 'drewmwilson@mailinator.com' already exists"
 }
 })
 
 */

#pragma mark - Server utilities
- (void)disableCacheForOperation:(AFJSONRequestOperation *)operation
{
    [operation setCacheResponseBlock:^NSCachedURLResponse *(NSURLConnection *connection, NSCachedURLResponse *cachedResponse) {
        // don't cache
        return nil;
    }];
}

/*
 https://filethis.com/ftapi/ftapi?
 op=ping&flex=true&resetexpire=false&ticket=9vk8Ei7FhbjTed81uMjmQjBIbIF
 args: resetexpire=false
 */
- (void)ping:(void (^)(void))success
{
    NSMutableURLRequest *req = [self requestForOperand:FTPing withParams:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:req
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            self.loginDisabled = NO;
            self.validated = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:FTPing object:nil];
            if (success)
                success();
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
        {
            self.loginDisabled = NO;
            self.validated = NO;
#ifdef ENABLE_NSLOG_REQUEST
            NSLog(@"Failed ping request: %@", error);
#endif
            [[NSNotificationCenter defaultCenter] postNotificationName:FTPing object:error];
        }];
    
    operation.queuePriority = NSOperationQueuePriorityVeryHigh;
    [self enqueueAuthenticatedOperation:operation];
}

#pragma mark - Server Requests

- (NSMutableDictionary *)paramsForOperand:(NSString *)operand withParams:(NSDictionary *)optionalParams
{
    NSMutableDictionary *params = [@{@"op" : operand, @"compact" : @"true"} mutableCopy];
    if (self.ticket)
        params[@"ticket"] = self.ticket;
        if (optionalParams)
            [params addEntriesFromDictionary:optionalParams];
    return params;
}

- (NSMutableURLRequest *)requestForOperand:(NSString *)operand withParams:(NSDictionary *)optionalParams
{
    NSMutableDictionary *params = [self paramsForOperand:operand withParams:optionalParams];
    params[@"json"] = @"true";
    return [self requestWithMethod:@"GET" path:@"/ftapi/ftapi" parameters:params];
}

// ref: http://madebymany.com/blog/url-encoding-an-nsstring-on-ios
- (NSString *)newUrlString:(NSString *)string {
    NSStringEncoding encoding = NSUTF8StringEncoding;
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
         NULL, (CFStringRef)string, NULL,
         (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
         CFStringConvertNSStringEncodingToEncoding(encoding)));
}

-(NSString *)encodeParamString:(NSDictionary *)parameters {
    NSMutableArray *paramsArray = [[NSMutableArray alloc] initWithCapacity:[parameters count]];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         NSString *objAsString = [obj description];
         NSString *urlEncodedString = [self newUrlString:objAsString];
         NSString *entry = [[NSString alloc] initWithFormat:@"%@=%@",key, urlEncodedString];
         [paramsArray addObject:entry];
     }];
    NSString *paramString = [paramsArray componentsJoinedByString:@"&"];
    return paramString;
}

- (NSMutableURLRequest *)createPostRequest:(NSString *)operand withParameters:(NSDictionary *)optionalParameters withXml:(NSString *)xml
{
    NSDictionary *params = [self paramsForOperand:operand withParams:optionalParameters];
    NSString *paramsString = [self encodeParamString:params];
    NSString *uri = [NSString stringWithFormat:@"?%@", paramsString];
    NSURL *url = [[NSURL alloc] initWithString:uri relativeToURL:[FTSession restURL]];
    NSMutableURLRequest *r = [[NSMutableURLRequest alloc] initWithURL:url];
    [r setHTTPMethod:@"POST"];
    [r setValue:@"text/xml" forHTTPHeaderField:@"Accept"];
    [r setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    if (xml)
        [r setHTTPBody:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    
    return r;
}

- (AFJSONRequestOperation *)getInstitutions:(void (^)(id JSON))success
{
#ifdef ENABLE_NSLOG_REQUEST
    NSLog(@"requesting institutions");
#endif
    NSMutableURLRequest *req = [self requestForOperand:FTListInstitutions withParams:nil];
    AFJSONRequestOperation *op = [[AFJSONRequestOperation alloc] initWithRequest:req];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        success(JSON);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (![operation isCancelled])
            [self handleError:error withTitle:@"" withResponse:operation.response];
    }];
    
    return op;
}

- (AFJSONRequestOperation *)getConnections:(void (^)(id JSON))success
{
#ifdef ENABLE_NSLOG_REQUEST
    NSLog(@"requesting connections");
#endif
    NSMutableURLRequest *request = [self requestForOperand:FTListConnections withParams:nil];
    AFJSONRequestOperation *op = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
#ifdef ENABLE_NSLOG_REQUEST
        NSLog(@"Response for connlist request: %@", JSON);
#endif
        success(JSON);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // retry connections request if error is out of user's control...
        // TODO: should we just retry connection request any time it fails?
        if ([error.domain isEqualToString:NSURLErrorDomain] && (error.code == NSURLErrorServerCertificateUntrusted || error.code == NSURLErrorCannotFindHost))
        {
#ifdef ENABLE_NSLOG_REQUEST
            NSLog(@"rescheduling connection request after failed request (error=%d)", error.code);
#endif
            double delayInSeconds = 0.5;
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, queue, ^(void){
                [self requestConnectionsList];
            });
        } else {
            if (![operation isCancelled])
                [self handleError:error withTitle:@"" withResponse:operation.response];
        }
    }];
    
    [self disableCacheForOperation:op];
    return op;
}

- (AFJSONRequestOperation *)getCurrentDestinationOperation
{
    NSString *operand = FTCurrentDestinationUpdated;
    NSURLRequest *request = [self requestForOperand:operand withParams:nil];
    AFJSONRequestOperation *op = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        
        if ([NSThread isMainThread])
            NSLog(@"getCurrentDestinationOperation - isMainThread");
        else
            NSLog(@"getCurrentDestinationOperation - NOT isMainThread");
        
#ifdef ENABLE_NSLOG_REQUEST
        NSLog(@"AFN got destination connections response=%@", JSON);
#endif
        NSArray *jsons = JSON[@"connections"];
        NSAssert1([jsons count] <= 1, @"should only have one destination connection, not %@", jsons);
        FTDestinationConnection *currentDestination;
        if ([jsons count] == 1)
            currentDestination = [[FTDestinationConnection alloc] initWithDictionary:jsons[0]];
        
        //Cuong: debug crash
#ifdef DEBUG_TEST_NULL_CURRENT_DESTINATION_AFTER_REACTIVATING_APP
        if (!self.app_is_reactivating) {
            self.app_is_reactivating = YES;
            currentDestination = nil;
        }
#endif
        
        if (currentDestination != nil) {
            _currentDestination = currentDestination;
            if (currentDestination.needsAuthentication || currentDestination.needsRepair) {
                [[NSNotificationCenter defaultCenter] postNotificationName:FTFixCurrentDestination object:currentDestination userInfo:nil];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:operand object:currentDestination userInfo:nil];
            }
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:FTMissingCurrentDestination object:currentDestination userInfo:nil];
        }
        CLS_LOG(@"Current destination id: %i, name: %@", _currentDestination.destinationId, _currentDestination.name);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (![operation isCancelled])
            [self handleError:error withTitle:@"" withResponse:operation.response];
        [[NSNotificationCenter defaultCenter] postNotificationName:FTFixCurrentDestination object:nil userInfo:nil]; //Post this event to stop loading data
    }];
    
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
//            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//                NSLog(@"AFN got destination connections response=%@", JSON);
//                NSArray *jsons = JSON[@"connections"];
//                NSAssert1([jsons count] <= 1, @"should only have one destination connection, not %@", jsons);
//                FTDestinationConnection *currentDestination;
//                if ([jsons count] == 1)
//                    currentDestination = [[FTDestinationConnection alloc] initWithDictionary:jsons[0]];
//                
//                if (currentDestination != nil) {
//                    _currentDestination = currentDestination;
//                    if (currentDestination.needsAuthentication || currentDestination.needsRepair) {
//                        [[NSNotificationCenter defaultCenter]
//                         postNotificationName:FTFixCurrentDestination object:currentDestination userInfo:nil];
//                    } else {
//                        [[NSNotificationCenter defaultCenter]
//                         postNotificationName:operand object:currentDestination userInfo:nil];
//                    }
//                } else {
//                    [[NSNotificationCenter defaultCenter]
//                     postNotificationName:FTMissingCurrentDestination object:currentDestination userInfo:nil];
//                }
//                NSLog(@"current destination is %@", _currentDestination);
//            }
//            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//                // TODO: do this on main thread
//                dispatch_block_t block = ^{
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"FileThis Destination" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                    [alert show];
//                };
//                runOnMainQueueWithoutDeadlocking(block);
//            }];
//
    [self disableCacheForOperation:op];
    return op;
}

- (void)getAccountPreferences:(void (^)(FTAccountSettings *settings))success
{
    NSMutableURLRequest *req = [self requestForOperand:FTGetAccountInfo withParams:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:req
            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                id prefs = JSON[@"account"];
                self.settings = [[FTAccountSettings alloc] initWithDictionary:prefs];
                if (success != nil)
                    success(self.settings);
                [[NSNotificationCenter defaultCenter] postNotificationName:FTGetAccountInfo object:self.settings userInfo:nil];
            }
            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                [self handleError:error withTitle:@"" withResponse:response];
            }];
    [self disableCacheForOperation:operation];
    [self enqueueAuthenticatedOperation:operation];
}

- (void)getProductIdentifiers
{
    NSMutableURLRequest *req = [self requestForOperand:FTGetProductIdentifiers withParams:nil];
    AFJSONRequestOperation *op = [[AFJSONRequestOperation alloc] initWithRequest:req];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *products = JSON[@"products"];
        NSMutableDictionary *productMapping = [NSMutableDictionary dictionaryWithCapacity:products.count];
        for (NSDictionary *product in products) {
            NSString *fileThisKey = product[@"filethis"];
            NSString *productIdentifer = product[@"apple"];
            productMapping[fileThisKey] = productIdentifer;
        }
        self.products = [NSDictionary dictionaryWithDictionary:productMapping];
        [[NSNotificationCenter defaultCenter] postNotificationName:FTGetProductIdentifiers object:self.products userInfo:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (![operation isCancelled])
            [self handleError:error withTitle:@""  withResponse:operation.response];
    }];
    
    [self disableCacheForOperation:op];
    [self enqueueAuthenticatedOperation:op];
}

/*
 
    https://staging.filethis.com/ftapi/ftapi?op=connecttodestination&flex=true&json=true&compact=true&id=3&browseable=false&ticket=QTujRGXxNqOFExWOJOOcEUAMjHy

*/
- (void)getAuthenticationURLForDestination:(NSInteger) destinationId withSuccess:(void (^)(id JSON))success
{
    NSMutableURLRequest *req = [self requestForOperand:FTConnectToDestination
                                                withParams:@{@"id":@(destinationId),
                                    @"browseable" : @"false",
                                    @"flex" : @"true"}];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:req
            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                success(JSON);
            }
            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                [self handleError:error withTitle:@"" withResponse:response];
            }];
    
    [self enqueueAuthenticatedOperation:operation];
}

//Cuong
- (void)connectToDestination:(NSInteger)destinationId username:(NSString*)username password:(NSString*)password withSuccess:(void (^)(id JSON))success {
    NSMutableURLRequest *req = [self requestForOperand:FTConnectToDestination
                                            withParams:@{@"id":@(destinationId),
                                                         @"username" : username,
                                                         @"password" : password,
                                                         @"browseable" : @"false",
                                                         @"flex" : @"true"}];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:req
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            success(JSON);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [self handleError:error withTitle:@"Cannot verify destination credentials" withResponse:response];
                                                                                        }];
    
    [self enqueueAuthenticatedOperation:operation];
}

- (void)verifyDestinationAuthorization:(NSURL *)url
                           withSuccess:(void (^)(NSInteger statusCode))success
                             orFailure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    // NOTE: this uses HTTP because success page doesn't support JSON, only HTML
    AFHTTPRequestOperation *op = [self HTTPRequestOperationWithRequest:req
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            success(operation.response.statusCode);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self handleError:error withTitle:@"Cannot Verify Authorization" withResponse:operation.response];
            failure(operation.request, operation.response, error);
        }];
    [self enqueueAuthenticatedOperation:op];
}


- (AFJSONRequestOperation *)loginOperationWithUser:(NSString *)username withPassword:(NSString *)password
onSuccess:(void (^)(id JSON))success
onFailure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    NSMutableURLRequest *req = [self requestForOperand:FTLoginNotification
                                                withParams:@{@"email":username, @"password" : password}];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:req
       success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
           success(JSON);
       }
       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
           failure(request, response, error);
       }];
    
    return operation;
}

- (void)login:(NSString *)username
 withPassword:(NSString *)password
    onSuccess:(void (^)(id JSON))success
    onFailure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    AFJSONRequestOperation *operation = [self loginOperationWithUser:username withPassword:password onSuccess:success onFailure:failure];
    operation.queuePriority = NSOperationQueuePriorityVeryHigh;
    [self disableCacheForOperation:operation];
    [self enqueueHTTPRequestOperation:operation];
}


- (AFJSONRequestOperation *)renewPasswordOperationWithUser:(NSString *)username withPassword:(NSString *)password
                                         onSuccess:(void (^)(id JSON))success
                                         onFailure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    NSMutableURLRequest *req = [self requestForOperand:FTRenewPasswordNotification
                                            withParams:@{@"email":username, @"password" : password, @"password-repeat" : password}];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:req
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            success(JSON);
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            failure(request, response, error);
                                                                                        }];
    
    return operation;
}

- (void)renewPassword:(NSString *)username
 withPassword:(NSString *)password
    onSuccess:(void (^)(id JSON))success
    onFailure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    AFJSONRequestOperation *operation = [self renewPasswordOperationWithUser:username withPassword:password onSuccess:success onFailure:failure];
    operation.queuePriority = NSOperationQueuePriorityVeryHigh;
    [self disableCacheForOperation:operation];
    [self enqueueHTTPRequestOperation:operation];
}

- (BOOL)isHTMLMessage:(NSString *)message
{
    NSRange r = [message rangeOfString:@"<html><body>"];
    return (r.length != 0);
}

- (NSString *)stripHTMLFromMessage:(NSString *)message
{
    NSRange r = [message rangeOfString:@"<html><body><h1>503 Service Unavailable</h1>"];
    if (r.length != NSNotFound)
        return NSLocalizedString(@"No server is available to handle this request.", @"No server is available to handle this request.");
    
    // TODO: implement strip html from message
    return message;
}

- (void)presentError:(NSError *)error withTitle:(NSString *)title {
    if (title == nil)
        title = @"FileThis Error";
/* handle HTML messages like this:
     NSString *testMessage = @"<html><body><h1>503 Service Unavailable</h1>\n\nNo server is available to handle this request.\n</body></html>";
*/
    NSString *m = error.localizedRecoverySuggestion;
    if ([self isHTMLMessage:m])
        m = [self stripHTMLFromMessage:m];
    if (!m)
        m = error.localizedDescription;
    if (error.userInfo[@"NSDebugDescription"])
        m = [m stringByAppendingFormat:@"\n%@", error.userInfo[@"NSDebugDescription"]];
    
    CLS_LOG(@"Operation failed: %@, error=%@", m, error);

    // extract operand from URL string
    dispatch_block_t block = ^{
        [[[UIAlertView alloc] initWithTitle:title message:m delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    };
    runOnMainQueueWithoutDeadlocking(block);
}

- (void)handleError:(NSError *)error forOperation:(AFHTTPRequestOperation *)operation withTitle:(NSString *)title {
    [self handleError:error withTitle:title withResponse:operation.response];
}

- (void)handleError:(NSError *)error forResponse:(NSHTTPURLResponse *)response withTitle:(NSString *)title {
    [self handleError:error withTitle:title withResponse:response];
}

- (void)handleError:(NSError *)error withTitle:(NSString *)title withResponse:(NSHTTPURLResponse *)response
{
    NSLog(@"Operation failed: %@. Response:%@", error, response);
    
    static const int NS_ERROR_USER_CANCELLED = -999;
    if (error.code == NS_ERROR_USER_CANCELLED)
        return;
    NSString *message = error.localizedDescription;
    NSString *suggestion = error.localizedRecoverySuggestion;
    static NSRegularExpression *extractFTException = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *reError;
        extractFTException = [NSRegularExpression
                    regularExpressionWithPattern:@"com.filethis.common.exception.(\\w+):(.+)"
                      options:nil error:&reError];
        NSAssert1(reError == nil, @"error for re: %@", reError);
    });
    if (suggestion)
    {
        BOOL isTimeout = [suggestion rangeOfString:FT_ExpiredTicketExceptionString].location != NSNotFound;
        BOOL is503 = [suggestion rangeOfString:@"503 Service Unavailable"].location != NSNotFound;
        if (isTimeout)
            message = @"Your session has expired.";
        else if (is503)
            message = NSLocalizedString(@"Servers are down. Please retry in 5 minutes", @"");
        BOOL logOut = isTimeout || is503;
        BOOL isLoggedOut = self.ticket == nil;
        if (logOut && !isLoggedOut) {
            [self reset];
            UINavigationController *root;
            //root = (UINavigationController *) [[[UIApplication sharedApplication] keyWindow] rootViewController];
            FTMobileAppDelegate *app = (FTMobileAppDelegate*)[UIApplication sharedApplication].delegate;
            root = app.navigationController; //Loc Cao
            if ([root isKindOfClass:[UINavigationController class]]) {
                [root popToRootViewControllerAnimated:YES];
            }
        } else {
            //+++Loc Cao
            NSError *reError;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"com.filethis.common.exception.(\\w+):(.+)" options:NSRegularExpressionCaseInsensitive error:&reError];
            NSTextCheckingResult *textCheckingResult = [regex firstMatchInString:suggestion options:0 range:NSMakeRange(0, suggestion.length)];
            if (textCheckingResult.numberOfRanges >= 3) {
                NSRange matchRange = [textCheckingResult rangeAtIndex:2];
                NSString *match = [suggestion substringWithRange:matchRange];
                if (match.length > 0) {
                    message = match;
                } else {
                    message = suggestion;
                }
            }
            //---
        }
    } else {
        if ([self isHTMLMessage:message])
            message = [self stripHTMLFromMessage:message];
    }
    
    if (error.code == DOMAIN_ERROR_CODE) {
        message = NSLocalizedString(@"ID_COMMUNICATION_COMMON_ERROR", @"");
    }
    
    time_t now;
    time(&now);
    BOOL tooSoon = now - self.lastErrorTime < 2;
    BOOL errorRepeating = [error.localizedDescription isEqualToString:self.lastErrorDescription];
    BOOL displayError = !errorRepeating || !tooSoon;
    self.lastErrorTime = now;
    self.lastErrorDescription = error.localizedDescription;
    
    if (message && displayError) {
        dispatch_block_t block = ^{
            [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        };
        runOnMainQueueWithoutDeadlocking(block);
    }
}

#pragma mark - FTAccountSettings

/*
 https://staging.filethis.com/
 ftapi/ftapi?op=accountupdate&flex=true&ticket=hZa4j7F5dQxCVMI8QRZtXJipksF
 POST
 
 build up request that looks like this:
 <request>
 <account>
 <users>
 <user/>
 </users>
 <timeoutMinutes>1440</timeoutMinutes>
 <emailSuccess>false</emailSuccess>
 </account>
 </request>
 
 NOTE: doesn't work as JSON
 returns :{"errorType":"com.filethis.common.exception.FTException","errorMessage":"Failed to read incoming XML Document\n"}
 
 */
- (NSString *)xmlFromDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *snippets = [NSMutableArray array];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop) {
        NSString *xmlSnippet;
        if ([obj isKindOfClass:[NSDictionary class]]) {
            if ([key isEqualToString:@"user"]) {
                key = @"users";
                if ([obj count] == 0)
                    obj = @"<user />";
                else
                    obj = [NSString stringWithFormat:@"<user>%@</user>", [self xmlFromDictionary:obj]];
            } else {
                obj = [self xmlFromDictionary:obj];
            }
        } else if ([obj isKindOfClass:[NSArray class]]) {
            NSAssert(NO,@"cheap xml doesn't support arrays");
        }
        xmlSnippet = [NSString stringWithFormat:@"<%@>%@</%@>",key, obj, key];
        [snippets addObject:xmlSnippet];
    }];
    
    NSString *xml = [snippets componentsJoinedByString:@"\n"];
    return xml;
}

-(void)saveSettings:(NSDictionary *)update {
    // FIXME: it'd be nice if server supported json payload so we don't have to convert to xml
    NSString    *xmlString = [self xmlFromDictionary:update];
    NSMutableURLRequest *req = [[FTSession sharedSession] createPostRequest:FTPatchAccountInfo withParameters:nil withXml:xmlString];
	AFHTTPRequestOperation *op = [self HTTPRequestOperationWithRequest:req
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self getAccountPreferences:nil];
            }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self handleError:error withTitle:@"Cannot save changes" withResponse:operation.response];
          } ];
    [self enqueueAuthenticatedOperation:op];
}

-(void)createUser:(NSDictionary *)params onSuccess:(void (^)(id))success onFailure:(void (^)(void))failure {
    NSMutableURLRequest *req = [self requestForOperand:FTCreateUser withParams:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:req
                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                success(JSON);
                            }
                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                [self handleError:error withTitle:@"Cannot Create New User" withResponse:response];
                                failure();
                            }];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)enqueueAuthenticatedOperation:(AFHTTPRequestOperation *)operation {
    @synchronized(self) {
        if (self.ticket) {
            if (![self.operationQueue.operations containsObject:operation])
                [self.operationQueue addOperation:operation];
        } else
            NSLog(@"cannot request without authentication");
    }
}

- (void)enqueueProcessingOperation:(NSOperation *)operation {
    @synchronized(self) {   //Cuong: try to avoid crash: Fatal Exception NSInvalidArgumentException *** -[NSOperationQueue addOperation:]: operation is already enqueued on a queue
        if (![self.processingQueue.operations containsObject:operation])
            [self.processingQueue addOperation:operation];
    }
}

- (void)checkQueues {
#ifdef ENABLE_NSLOG_REQUEST
    NSLog(@"%d operations in %@", self.processingQueue.operationCount, self.processingQueue.name);
    for (NSOperation *op in self.processingQueue.operations) {
        NSLog(@"op %@, ready=%d, executing=%d, cancelled=%d, concurrent=%d, %@", op,
              op.isReady, op.isCancelled, op.isExecuting, op.isConcurrent, op.dependencies);
    }
    NSLog(@"%d operations in %@", self.operationQueue.operationCount, self.operationQueue.name);
    for (NSOperation *op in self.operationQueue.operations) {
        NSLog(@"op %@, ready=%d, executing=%d, cancelled=%d, concurrent=%d, %@", op,
              op.isReady, op.isCancelled, op.isExecuting, op.isConcurrent, op.dependencies);
    }
#endif

    if (self.processingQueue.operationCount > 0)
        [self performSelector:@selector(checkQueues) withObject:nil afterDelay:15.0];
}

/* load all the data required to login
 
    Data required to login:
        institutions
        connections - dependent on institutions because a connections uses an
            institution's logo and name.
        destinations
        current destination
 
 */

- (void)loadDestinations {
    // only request destinations if we haven't already loaded them...
    AFJSONRequestOperation *destinationsOperation = nil;
    if (!self.destinations) {
        destinationsOperation = [self getDestinations];
        [self enqueueHTTPRequestOperation:destinationsOperation];
    }
    
    AFJSONRequestOperation *currentDestinationOperation = [self getCurrentDestinationOperation];
    
    if (destinationsOperation)
        [currentDestinationOperation addDependency:destinationsOperation];
    [self enqueueHTTPRequestOperation:currentDestinationOperation];
}

- (void)startup {
    self.validated = YES;
    ProcessInstitutionsOperation *processInstitutions = nil;
    AFJSONRequestOperation *getInstitutions = nil;
    
    //moved code to loadDestinations...
    
    if (!self.institutions) {
        NSURLRequest *req = [self requestForOperand:FTListInstitutions withParams:nil];
        getInstitutions = [AFJSONRequestOperation JSONRequestOperationWithRequest:req
            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                NSAssert1(JSON[@"institutions"] != nil, @"JSON[institutions] is nil? %@", JSON);
                [ProcessInstitutionsOperation processInstitutions:JSON[@"institutions"]];
#ifdef ENABLE_NSLOG_REQUEST
                NSLog(@"getInstitutions finished=%d", getInstitutions.isFinished);
#endif
                [self performSelector:@selector(checkQueues) withObject:nil afterDelay:0.0];
            }
            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
            {
                [self handleError:error withTitle:@"" withResponse:response];
            }];
        
//        getInstitutions = [self getInstitutions:^(id JSON) {
//            // NOTE: we do this on main thread because I couldn't debug
//            // intermittent problem passing nil json to ProcessInstitutionsOperation.
//            // Running on main thread (and inside this block seems to solve this).
////            [FTInstitution processInstitutions:rawInstitutions];
//            //        processInstitutionsOperation.json = JSON;
//        }];
//        [getInstitutions setThreadPriority:1.0];
//        [processInstitutions addDependency:getInstitutions];
        [self enqueueHTTPRequestOperation:getInstitutions];
//        [self enqueueProcessingOperation:processInstitutions];
    }
    
    // schedule processing of institutions list
//    [processInstitutionsOperation addDependency:institutionsOperation];
    
    (void) [self resetConnectionsRequest];
//    NSAssert(reset, @"connections should be reset at load");

    // schedule processing of connections AFTER processing institutitions
    if (processInstitutions)
        [self.connectionsResponseProcessor addDependency:processInstitutions];

    if (!self.connectionsRequestOperation.isFinished) {
        [self enqueueHTTPRequestOperation:self.connectionsRequestOperation];
        [self enqueueProcessingOperation:self.connectionsResponseProcessor];
    } else {
        // FIXME: why is connections request already finished?
        CLS_LOG(@"connections request is already finished at startup?");
    }

    NSTimeInterval delayInSeconds = 1.0; // 1s
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(popTime, queue, ^(void){
        [self delayedInitialization];
    });
}

- (BOOL)isUsingFTDestination {
    if (self.currentDestination) {
        FTDestination *dest = [FTDestination destinationWithId:self.currentDestination.destinationId];
        if (dest) {
            if ([dest.provider isEqualToString:@"this"]) {
                return YES;
            }
        }
    }
    return NO;
}
@end
