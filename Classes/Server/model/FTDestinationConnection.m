//
//  FTDestinationConnection.m
//  FileThis
//
//  Created by Drew Wilson on 1/6/13.
//

#import "ENSearchRequest.h"

#import "FTDestination.h"
#import "FTDestinationConnection.h"
#import "Endian.h"

typedef enum {
    DestinationNoneState = 'none',
    DestinationNeedAuthorizationState = 'auth',
    DestinationErrorState = 'erro',
    DestinationReadyState = 'redy'
} DestinationState;

typedef enum {
    DestinationNoError = 'none',
    DestinationAuthInvalidError = 'ainv',
    DestinationAuthExpiredError = 'aexp',
    DestinationNotPermittedError = 'nper',
    DestinationQuotaExceededError = 'qexc',
    DestinationUnexpectedError = 'unex'
} DestinationError;

@interface FTDestinationConnection ()

/*
 
 public static const STATE_NONE:String = "none";
 public static const STATE_WAIT_USER_AUTHORIZE:String = "auth";
 public static const STATE_ERROR:String = "erro";
 public static const STATE_READY:String = "redy";
 
 public static const ERROR_NONE:String = "none";
 public static const ERROR_AUTH_INVALID:String = 'ainv';
 public static const ERROR_AUTH_EXPIRED:String = 'aexp';
 public static const ERROR_NOT_PERMITTED:String = 'nper';
 public static const ERROR_QUOTA_EXCEEDED:String = 'qexc';
 public static const ERROR_UNEXPECTED:String = 'unex';
 
 "type" can be "conn", "host", or?
*/

@property NSString *type;
@property DestinationState state;
@property DestinationError error;
@property NSString *errorString;
@property Boolean  browseable;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userEmail;
@property BOOL isEvernote;


@end

@implementation FTDestinationConnection


/*

 browseable = 0;
 destinationId = 3;
 error = aexp;
 id = 3;
 name = Evernote;
 rootFolderGuid = "";
 rootTagGuid = "";
 settings = "e30=";
 state = redy;
 type = conn;
 userName = filethisfetchdrew;

 
 {
 "connections": [{
 "id": 3,
 "destinationId": 3,
 "name": "Evernote",
 "type": "conn",
 "state": "redy",
 "error": "unex",
 "browseable": false,
 "settings": "e30=",
 "userName": "prod_fetch20"
 }]
 }*/
/*
 
 "connections": [{
 "id": 8,
 "destinationId": 8,
 "name": "Google Drive",
 "type": "conn",
 "state": "redy",
 "error": "none",
 "browseable": false,
 "settings": "e30=",
 "userName": "Brian Berson",
 "userEmail": "brianberson@pacbell.net",
 "userPicture": "https://lh3.googleusercontent.com/-9qNZA3ITQMA/AAAAAAAAAAI/AAAAAAAAAH0/Xg0R-PPvnuQ/photo.jpg"
 }]
 }*/


- (id)initWithDictionary:(NSDictionary *)dictionary
{
#ifdef DEBUG
    NSLog(@"DestinationConnection dictionary=%@", dictionary);
#endif
    if ((self = [super init])) {
        self.destinationConnectionId = [dictionary[@"id"] integerValue];
        self.name = dictionary[@"name"];
        self.destinationId = [dictionary[@"destinationId"] integerValue];
        
        self.state = EndianU32_BtoN(*(FourCharCode *) [dictionary[@"state"] UTF8String]);
        self.errorString = dictionary[@"error"];
        self.error = EndianU32_BtoN(*(FourCharCode *) [self.errorString UTF8String]);
        self.type = dictionary[@"type"];

        self.userName = dictionary[@"userName"];
        self.userEmail = dictionary[@"userEmail"];
        // TODO: add support for Google Drive's userPicture,
        // which is a URL to an image.
//        self.userPictureUrl = dictionary[@"userPicture"];
//        self.browseable = dictionary[@"browseable"];
        
        FTDestination *destination = [FTDestination destinationWithId:self.destinationId];
        if (destination) {
#define EVERNOTE_CRASHES_ON_IPHONE  1
#if EVERNOTE_CRASHES_ON_IPHONE
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
#endif
            self.isEvernote = [destination.name rangeOfString:@"vernote" options:NSCaseInsensitiveSearch].length != 0;
#if EVERNOTE_CRASHES_ON_IPHONE
            }
#endif
        }
#ifdef DEBUG
        NSLog(@"Destination Connection #%d %@ has attributes: %@", self.destinationConnectionId, self.name, dictionary);
#endif
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@ id=%d destinationId=%d state=%@ error=%@",
        [super description], self.name, self.destinationConnectionId,
            self.destinationId, self.stateString, self.errorString];
}

- (NSString *)errorDescription {
    switch (self.error) {
        case DestinationNoError:
            return nil;
        case DestinationAuthExpiredError:
            return NSLocalizedString(@"Authorization has expired", @"current destination error description");
        case DestinationAuthInvalidError:
            return NSLocalizedString(@"Authorization failed", @"current destination error description");
        case DestinationNotPermittedError:
            return NSLocalizedString(@"The destination does not permit that operation", @"current destination error description");
        case DestinationQuotaExceededError:
            return NSLocalizedString(@"You have exceeded your destination's storage quota", @"current destination error description");
        case DestinationUnexpectedError:
            return NSLocalizedString(@"Your destination returned an unexpected error", @"current destination error description");
    }
    return nil;
}

- (BOOL)needsRepair {
    return self.state == DestinationErrorState && [self errorDescription] != nil;
}

- (BOOL)needsAuthentication
{
    return self.state == DestinationNeedAuthorizationState;
}

- (NSString *)stateString {
    switch (self.state) {
        case DestinationReadyState:
            return NSLocalizedString(@"Ready for documents", @"Destination state redy");
        case DestinationErrorState:
            return @"Error";
        case DestinationNeedAuthorizationState:
            return @"Needs Authorization";
        case DestinationNoneState:
//        default:
            break;
    }
    return @"None";
}


/*        
 "userName": "Prod_box3 Filethis",
 "userEmail": "Prod_box3@filethis.com"
 */
- (NSString *)userString {
    if (self.userEmail)
        return [NSString stringWithFormat:@"%@ (%@)", self.userName, self.userEmail];
    else
        return self.userName;
}

-(NSString *)statusString {
    NSString *connectedAs = nil;
    if (self.userString) {
        connectedAs = [NSString stringWithFormat:@"Connected as %@", self.userString];
        return [@[self.stateString, connectedAs] componentsJoinedByString:@"\n"];
    }
    
    return self.stateString;
}

- (NSURL *)documentsURL {
    static NSDictionary *urlStrings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        urlStrings = @{
             @"Evernote" : @"en://app-bridge/consumerKey/FileThis/pasteBoardName/com.evernote.bridge.FileThis",
             @"Evernote Business" : @"en://app-bridge/consumerKey/FileThis/pasteBoardName/com.evernote.bridge.FileThis://",
             @"Personal" : @"prsnl://tag/FileThis/show"};
    });    
    NSString *urlString = urlStrings[ self.name ];
    NSURL *url = nil;
    if (urlString)
        url = [NSURL URLWithString:urlString];
    return url;
}

- (NSURL *)applicationURL {
    NSURL *url = [self documentsURL];
    if (url == nil) {
        static NSDictionary *urlStrings = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            urlStrings = @{
                 @"Dropbox" : @"dbapi-1://",
                 @"Box" : @"box://",
                 @"Google Drive" : @"googledrive://"};
        });
        NSString *urlString = [urlStrings objectForKey:self.name];
        if (urlString && urlString.length > 0)
            url = [NSURL URLWithString:urlString];
    }
    return url;
}

- (BOOL)canLaunchToDocuments {
    NSURL *url = [self documentsURL];
    BOOL ok = url != nil && [[UIApplication sharedApplication] canOpenURL:url];
    return ok;
}

- (BOOL)canLaunchApplication {
    NSURL *url = [self applicationURL];
    return url != nil && [[UIApplication sharedApplication] canOpenURL:url];
}

- (void)launchApplication {
    NSURL *url = [self applicationURL];
    NSString *message;
    if (url != nil) {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            if (self.isEvernote)
                [self openInEvernote];
            else
                [[UIApplication sharedApplication] openURL:url];
        }
        else {
            NSString *f = NSLocalizedString(@"%@ cannot be opened because it is not installed.", @"");
            message = [NSString stringWithFormat:f, self.name];
        }
    } else {
        NSString *f = NSLocalizedString(@"%@ is not supported at this time.", @"");
        message = [NSString stringWithFormat:f, self.name];
    }

    if (message)
        [[[UIAlertView alloc] initWithTitle:@"Cannot Open Destination" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

// copy Evernote constants to avoid pulling in Evernote SDK

// constants from ENApplicationBridge.m
const uint32_t kEN_ApplicationBridge_DataVersion = 0x00010000;
NSString * const kEN_ApplicationBridge_DataVersionKey = @"$dataVersion$";
NSString * const kEN_ApplicationBridge_CallBackURLKey = @"$callbackURL$";
NSString * const kEN_ApplicationBridge_RequestIdentifierKey = @"$requestIdentifier$";
NSString * const kEN_ApplicationBridge_RequestDataKey = @"$requestData$";
NSString * const kEN_ApplicationBridge_CallerAppNameKey = @"$callerAppName$";
NSString * const kEN_ApplicationBridge_CallerAppIdentifierKey = @"$callerAppIdentifier$";
NSString * const kEN_ApplicationBridge_ConsumerKey = @"$consumerKey$";
NSString * const evernoteConsumerKey = @"FileThis";

- (void)putEvernoteQueryOntoPasteboard {
    NSString *query = @"stack:\"FileThis\"";
    NSMutableDictionary* appBridgeData = [NSMutableDictionary dictionary];
    ENSearchRequest* request = [[ENSearchRequest alloc] init];
    [request setQueryString:query];
    
    NSData *requestData = [NSKeyedArchiver archivedDataWithRootObject:request];
    [appBridgeData setObject:requestData forKey:kEN_ApplicationBridge_RequestDataKey];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    if (infoDictionary != nil) {
        NSString *appIdentifier = [infoDictionary objectForKey:(NSString *)kCFBundleIdentifierKey];
        if (appIdentifier != nil) {
            [appBridgeData setObject:appIdentifier forKey:kEN_ApplicationBridge_CallerAppIdentifierKey];
        }
        NSString *appName = [infoDictionary objectForKey:(NSString *)kCFBundleNameKey];
        if (appName != nil) {
            [appBridgeData setObject:appName forKey:kEN_ApplicationBridge_CallerAppNameKey];
        }
    }
    [appBridgeData setObject:[NSNumber numberWithUnsignedInt:kEN_ApplicationBridge_DataVersion] forKey:kEN_ApplicationBridge_DataVersionKey];
    [appBridgeData setObject:[request requestIdentifier] forKey:kEN_ApplicationBridge_RequestIdentifierKey];
    [appBridgeData setObject:evernoteConsumerKey forKey:kEN_ApplicationBridge_ConsumerKey];
    NSString* pasteboardName = [NSString stringWithFormat:@"com.evernote.bridge.%@",evernoteConsumerKey];
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:pasteboardName create:YES];
    [pasteboard setPersistent:YES];
    [pasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:appBridgeData] forPasteboardType:@"$EvernoteApplicationBridgeData$"];
}

- (void)openInEvernote {
    [self putEvernoteQueryOntoPasteboard];
    NSURL *url = [self documentsURL];
//    NSString* pasteboardName = [NSString stringWithFormat:@"com.evernote.bridge.%@",evernoteConsumerKey];
//    NSString* openURL = [NSString stringWithFormat:@"en://app-bridge/consumerKey/%@/pasteBoardName/%@",evernoteConsumerKey,pasteboardName];
//    NSAssert([[url absoluteString] isEqualToString:openURL], @"urls match");
    [[UIApplication sharedApplication] openURL:url];
}

@end
