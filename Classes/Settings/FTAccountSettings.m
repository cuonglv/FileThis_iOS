//
//  FTAccountSettings.m
//  FileThis
//
//  Created by Drew Wilson on 12/12/12.
//
//

#import "AppleStoreObserver.h"
#import "FTAccountSettings.h"
#import "FTSession.h"
#import "UIKitExtensions.h"
#import "AFXMLRequestOperation.h"
#import "TimeoutSettingViewController.h"

@interface FTAccountSettings ()

@property (strong) NSMutableDictionary *store;
@property (strong) NSDictionary *original;
@property BOOL isSubscriber;

@end

/*
 
Store to convert account information from server to client side values for display.
Also converts a limited set of information from client side values to server side.

For generating the data for the account update, two things are important:
1. The users array is required, even if the user array is empty (<users><user/></users>).
 The 2-deep users/user tree is flattened for the client-side representation. This means
 all the settings can use keyvalue bindings (e.g. "user.email"), which simplifies the bindings.
2. The post data has to be XML, and Cocoa doesn't have a straight forward way of generating
 XML from a dictionary. So we have our own XML generator here. And it includes logic to handle
 the above requirement that a users element is always included.

 */

/*
 
 https://integration.filethis.com/ftapi/ftapi?op=accountinfo&flex=true&json=true&compact=true&ticket=SDUd64p7OAcWsSnPQBIeLWAxrtE	200	GET	integration.filethis.com	/ftapi/ftapi?op=accountinfo&flex=true&json=true&compact=true&ticket=SDUd64p7OAcWsSnPQBIeLWAxrtE	 115 ms	2.09 KB	Complete	
 
 https://integration.filethis.com/ftapi/ftapi
    ?op=accountinfo&flex=true&json=true&compact=true&ticket=SDUd64p7OAcWsSnPQBIeLWAxrtE
 
 Request:
 op	accountinfo
 flex	true
 json	true
 compact	true
 ticket	SDUd64p7OAcWsSnPQBIeLWAxrtE

account	Object
    name	String	Account 'drewsintegration@mailinator.com'
    id	Integer	183
    autoClassify	String	true
    useTimeout	String	true
    emailSuccess	String	true
    emailFailure	String	true
    emailCampaign	String	true
    renews	String	false
    timeoutMinutes	Integer	10
    priorClientIp	String	108.214.96.178
    priorLoginDate	Integer	1355272391
    docCount	Integer	0
    docBytes	Integer	0
    uploadEmailAddr	String	drewsintegration_at_mailinator.com@u.filethis.com
    type	String	conn
    level	String	free
    plan	String	none
    pendingPlan	String	none
    expires	Number	4133923200
    destinationId	Integer	8
    destinationState	String	auth
    destinationError	String	none
    destinationBrowseable	Boolean	true
    hasSubscription	String	false
    sourceConnectionQuota	Integer	6
    maxEnabledConnections	Integer	6
    storage	Integer	0
    storageQuota	Integer	100000
    docTypes	Array
    users	Array
        [0]	Object
            id	Integer	183
            email	String	drewsintegration@mailinator.com
            first	String	Drew
            last	String	Wilson
            created	Integer	1355269566
 
 */

/*
 
 {
 "account": {
 "name": "Account 'filethisfetchdrew@ymail.com'",
 "id": 204,
 "autoClassify": "true",
 "useTimeout": "false",
 "emailSuccess": "true",
 "emailFailure": "true",
 "emailCampaign": "true",
 "renews": "true",
 "timeoutMinutes": 0,
 "priorClientIp": "24.5.145.164",
 "priorLoginDate": 1367967773,
 "docCount": 644,
 "docBytes": 6000,
 "uploadEmailAddr": "filethisfetchdrew_at_ymail.com@u.filethis.com",
 "type": "conn",
 "billing": "appl",
 "level": "prem",
 "plan": "prem",
 "pendingPlan": "none",
 "expires": 1399493940,
 "destinationId": 4,
 "destinationState": "redy",
 "destinationError": "aexp",
 "destinationBrowseable": false,
 "destinationSettings": "e30=",
 "features": "e30=",
 "hasSubscription": "true",
 "sourceConnectionQuota": 12,
 "maxEnabledConnections": 12,
 "storage": 6,
 "storageQuota": 1000000,
 "docTypes": ["bmp", "doc", "docm", "docx", "dot", "dotm", "dotx", "gif", "htm", "html", "jpeg", "jpg", "odg", "odm", "ods", "odt", "otg", "oth", "ots", "ott", "pct", "pdf", "png", "pot", "potm", "potx", "pps", "ppt", "pptm", "pptx", "psd", "rtf", "stc", "sxc", "tif", "tiff", "txt", "wmf", "xls", "xlsb", "xlsm", "xlsx", "xlt", "xltm", "xltx", "xlw"],
 "users": [{
 "id": 204,
 "email": "filethisfetchdrew@ymail.com",
 "first": "Drew 9",
 "last": "Wilson",
 "created": 1364933991
 }]
 }
 }
 
 */

@implementation FTAccountSettings

- (void)applyPayment:(SKPaymentTransaction *)transaction {
    self.isSubscriber = YES;
    self.store[@"expires"] = [[transaction expiration] stringValue];
    NSString *productIdentifier = transaction.payment.productIdentifier;
    NSString *plan = [[AppleStoreObserver sharedObserver] localizedNameForAppleProductIdentifier:productIdentifier];
    self.store[@"plan"] = plan;
    self.store[@"billing"] = @"appl";
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        self.store = [self createClientSettingsFromServerSettings:dictionary];
        self.original = [self.store deepCopyDictionary];
    }
    return self;
}

#pragma mark - access User properties
- (id)userValueForKey:(NSString *)key {
    return [self.store valueForKey:@"users"][0][key];
}

- (void)setUserValue:(NSString *)value forKey:(NSString *)key {
    NSMutableArray *users = [self.store valueForKey:@"users"];
    users[0][key] = value;
    [self.store setObject:users forKey:@"users"];
//    NSMutableArray *users = [[self arrayForKey:@"users"] mutableCopy];
//    users[0][key] = value;
//    [self setObject:users forKey:@"users"];
}

#pragma mark - access boolean properties
// Override boolean accessors to use "true" and "false"
- (BOOL)boolForKey:(NSString *)defaultName {
    NSString *boolString = [self.store valueForKey:defaultName];
    return [boolString isEqualToString:@"true"] ?: 0;
}

- (void)setBool:(BOOL)value forKey:(NSString *)defaultName {
    NSString *boolString = value ? @"true" : @"false";
    [self.store setValue:boolString forKey:defaultName];
}

#pragma mark - Property accessors

- (NSString *)firstName {
    return [self userValueForKey:@"first"];
}

- (void)setFirstName:(NSString *)firstName {
    [self setUserValue:firstName forKey:@"first"];
}

- (NSString *)lastName {
    return [self userValueForKey:@"last"];
}

- (void)setLastName:(NSString *)lastName {
    [self setUserValue:lastName forKey:@"last"];
}

- (NSString *)email {
    return [self userValueForKey:@"email"];
}

- (void)setEmail:(NSString *)email {
    [self setUserValue:email forKey:@"email"];
}

- (NSInteger)logoutAfterMinutes {
    return [[self.store valueForKey:@"timeoutMinutes"] integerValue];
}

- (void)setLogoutAfterMinutes:(NSInteger)logoutAfterMinutes {
    [self.store setValue:[NSNumber numberWithInt:logoutAfterMinutes] forKey:@"timeoutMinutes"];
}

-(NSString *)memberSince {
    return [self userValueForKey:@"created"];
}

-(NSString *)lastLogin {
    return [self.store valueForKey:@"priorLoginDate"];
}

- (double)storage {
    return [[self.store valueForKey:@"storage"] doubleValue];
}

- (double)storageQuota {
    return [[self.store valueForKey:@"storageQuota"] doubleValue];
}

- (NSString *)autoRenewsOn {
    NSString *date = nil;
    if (self.isSubscriber) {
        NSString *number = [self.store valueForKey:@"expires"];
        if ([number intValue] != 0)
            date = [self dateStringFromEpoch:[NSNumber numberWithLongLong:[number longLongValue]]];
    }
    return date;
}

- (BOOL)emailCampaign {
    return [self boolForKey:@"emailCampaign"];
}

- (void)setEmailCampaign:(BOOL)emailCampaign {
    [self setBool:emailCampaign forKey:@"emailCampaign"];
}

- (BOOL)emailSuccesses {
    return [self boolForKey:@"emailSuccess"];
}

- (void)setEmailSuccesses:(BOOL)emailSuccess {
    [self setBool:emailSuccess forKey:@"emailSuccess"];
}

- (BOOL)emailFailures {
    return [self boolForKey:@"emailFailure"];
}

- (void)setEmailFailures:(BOOL)emailFailure {
    [self setBool:emailFailure forKey:@"emailFailure"];
}

- (BOOL)autoClassify {
    return [self boolForKey:@"autoClassify"];
}

- (void)setAutoClassify:(BOOL)value {
    [self setBool:value forKey:@"autoClassify"];
}

/*
 Other interesting properties related to customer's billing/subscription/plan:
    hasSubscription = true;
    level = prem;
    pendingPlan = none;
    plan = prem;
 
 */

/*
 The new "billing" property can have these values:
     public static const BILLING_NONE:String = "none";
     public static const BILLING_RECURLY:String = "recu";
     public static const BILLING_APPLE:String = "appl";
 */

-(BOOL)isApplePayment {
    NSString *paymentType = [self.store objectForKey:@"billing"];
    if (paymentType) {
        if ([paymentType isEqualToString:@"appl"])
            return YES;
    }
    return NO;
}

- (BOOL)isRecurringPayment {
    NSString *paymentType = [self.store objectForKey:@"billing"];
    if (paymentType) {
        return [paymentType isEqualToString:@"recu"] ? YES : NO;
    }
    return NO;
}

- (NSString *)localizedServicePlan {
    if (self.isSubscriber)
        return NSLocalizedString(self.store[@"plan"], @"service plan name");
    else
        return NSLocalizedString(@"none", @"service plan name");
}

- (NSString *)dateStringFromEpoch:(NSNumber *)epoch
{
    NSTimeInterval seconds = [epoch doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
//Cuong: ignore assert
//#ifndef NDEBUG
//    NSTimeInterval range = 60 /* seconds */ * 60 /* minutes */ * 24 /* hours */ * 365 /* days */ * 3 /* years */;
//    NSDate *min = [NSDate dateWithTimeIntervalSinceNow:-range];
//    NSDate *max = [NSDate dateWithTimeIntervalSinceNow:range];
//    assert([date compare:max] == NSOrderedAscending && "bad date?");
//    assert([date compare:min] == NSOrderedDescending && "bad date?");
//#endif
    return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)dateTimeStringFromEpoch:(NSNumber *)epoch {
    NSTimeInterval epochDouble = [epoch doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:epochDouble];
    NSDateFormatterStyle timeStyle = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ?
                    NSDateFormatterMediumStyle : NSDateFormatterShortStyle;
    NSDateFormatterStyle dateStyle = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ?
                    NSDateFormatterLongStyle : NSDateFormatterShortStyle;

    return [NSDateFormatter localizedStringFromDate:date dateStyle:dateStyle timeStyle:timeStyle];
}

#pragma mark - Property accessors - CRP
- (int)totalConnectionQuota {
    return [[self.store valueForKey:@"totalSourceConnectionQuota"] intValue];
}

- (double)totalStorageQuota {
    return [[self.store valueForKey:@"totalStorageQuota"] doubleValue];
}

- (int)totalConnectionUsage {
    return [[self.store valueForKey:@"totalSourceConnectionUsage"] intValue];
}

- (double)totalStorageUsage {
    return [[self.store valueForKey:@"totalStorageUsage"] doubleValue];
}

//---
- (int)subscriptConnectionQuota {
    return [[self.store valueForKey:@"subscriptionSourceConnectionQuota"] intValue];
}

- (double)subscriptStorageQuota {
    return [[self.store valueForKey:@"subscriptionStorageQuota"] doubleValue];
}

- (int)refConnectionQuota {
    return [[self.store valueForKey:@"referralSourceConnectionQuota"] intValue];
}

- (double)refStorageQuota {
    return [[self.store valueForKey:@"referralStorageQuota"] doubleValue];
}

- (NSString*)socialMediaMessage {
    return [self.store valueForKey:@"socialMediaMessage"];
}

#pragma mark Server-Side/Client-Side processing

// create subset of all settings
- (NSMutableDictionary *)createClientSettingsFromServerSettings:(NSDictionary *)serverSettings
{
    time_t now = time(NULL);
    time_t expiration = [serverSettings[@"expires"] longValue];
    BOOL expired = expiration < now;
    self.isSubscriber = !expired;

    NSMutableDictionary *client = [[NSMutableDictionary alloc] initWithCapacity:serverSettings.count];
    [serverSettings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         //         Other interesting properties related to customer's billing/subscription/plan:
         //         hasSubscription = true;
         //         level = prem;
         //         pendingPlan = none;
         //         plan = prem;

         if ([key isEqualToString:@"users"]) {
             NSMutableArray *users = [obj mutableCopy];
             for (NSInteger i = 0; i < [obj count]; i++) {
                 users[i] = [obj[i] deepCopyMutableDictionary];
                 users[i][@"created"] = [self dateStringFromEpoch:obj[i][@"created"]];
             }
             obj = users;
         } else if ([key isEqualToString:@"priorLoginDate"]) {
             obj = [self dateTimeStringFromEpoch:obj];
         } else if ([key isEqualToString:@"timeoutMinutes"]) {
             obj = [obj stringValue];
         }
         
         if (expired) {
             if ([key isEqualToString:@"hasSubscription"])
                 obj = [NSNumber numberWithBool:NO];
             else if ([key isEqualToString:@"plan"])
                 obj = @"none";
         }
        
         if (obj)
             client[key] = obj;
     }
     ];
    return client;
}

- (NSDictionary *)changes
{
    NSArray *   mutableKeys = @[@"timeoutMinutes", @"useTimeout", @"first", @"last", @"email",
                             @"emailSuccess", @"emailFailure", @"emailCampaign", @"autoClassify" ];
    NSMutableDictionary *updates = [[NSMutableDictionary alloc] initWithCapacity:mutableKeys.count];
    
    [self.store enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"users"]) {
            // just handle first user for now
            NSDictionary *userOriginal = self.original[@"users"][0];
            NSDictionary *userStored = self.store[@"users"][0];
            NSMutableDictionary *userChanges = [NSMutableDictionary dictionary];
            [userStored enumerateKeysAndObjectsUsingBlock:^(id k,id o,BOOL *quit) {
                if ([mutableKeys containsObject:k])
                {
                    if (![o isEqual:userOriginal[k]]) {
                        userChanges[k] = o;
                    }
                }
            }];
            if (userChanges.count > 0)
                updates[@"user"] = userChanges;
        } else if ([mutableKeys containsObject:key]) {
            
            id oldValue = [self.original objectForKey:key];
            if (![obj isEqual:oldValue]) {

                if ([key isEqualToString:@"timeoutMinutes"]) {
                    if ([obj integerValue] == 0)
                        updates[@"useTimeout"] = @"false";
                    else
                        updates[@"useTimeout"] = @"true";
                }
                
                updates[key] = obj;
            }
        }
    }];
    
    if ([updates count] == 0)
        return NULL;
    
    if (!updates[@"user"]) {
        updates[@"user"] = @{};
    }
    
    NSDictionary *accountUpdate = @{@"request" : @{@"account" : updates } };
    return accountUpdate;
}


// Write settings to a permanant storage
- (void)save
{
    NSDictionary *update = [self changes];
    if (update) {
        [[FTSession sharedSession] saveSettings:update];
    }
}

@end
