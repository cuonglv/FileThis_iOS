//
//  FTConnection.m
//  FileThis
//
//  Created by Drew on 5/6/12.
//  Copyright (c) 2012 filethis.com. All rights reserved.
//

#import "AFNetworking.h"

#import "FTConnection.h"
#import "FTInstitution.h"
#import "FTMobileAppDelegate.h"
#import "FTSession.h"

typedef enum {
    created, // Transitional state when connection has just been created
    waiting, // Idle state. Waiting for the "attempt" date to be reached
    connecting, // The fetcher is attempting to connect to the source.
    uploading, // The fetcher is actively fetching documents.
    question, // A question has been posed that the client must answer before fetching can proceed.
    answered, // The client has answered the question. Transitional state until the server tries to fetch again.
    manual, // I'll get you more info about this
    disabled, // and this
    incorrect, // and this
    error, // The fetch has failed. Client should show an error string based on the "state" and "info" fields
    
    idle = waiting
} FTConnectionState;

NSString *FT_CONNECTION_ID_KEY = @"id";

static NSString *WORKFLOW_STATE_CREATED = @"created";
static NSString *WORKFLOW_STATE_WAITING = @"waiting";
static NSString *WORKFLOW_STATE_CONNECTING = @"connecting";
static NSString *WORKFLOW_STATE_UPLOADING = @"uploading";
static NSString *WORKFLOW_STATE_QUESTION = @"question";
static NSString *WORKFLOW_STATE_ANSWERED = @"answered";
static NSString *WORKFLOW_STATE_MANUAL = @"manual";
static NSString *WORKFLOW_STATE_DISABLED = @"disabled";
static NSString *WORKFLOW_STATE_INCORRECT = @"incorrect";
static NSString *WORKFLOW_STATE_ERROR = @"error";

@interface UpdateConnectionOperation : AFHTTPRequestOperation

- (id)initForConnection:(FTConnection *)connection withChanges:(NSDictionary *)changes;

@end

@interface FTConnection () {
    NSURL *_iconURL;
}

@property (weak) FTSession *session;

/*
 {
 attempt = 1356421312;
 checked = 1355731200;
 documentCount = 0;
 enabled = 1;
 fetchAll = 1;
 id = 2206;
 info = "";
 institutionId = 1;
 name = "American Express #2";
 period = 1w;
 retries = 0;
 state = waiting;
 success = 1355791262;
 username = drewmwilson;
 }*/
@property NSDictionary *originalValues;
@property (strong,nonatomic) NSString *stateString;
@property FTConnectionState state;
@property FTInstitution *institution;
@property (strong) NSDate *attempt; // The timestamp (seconds in epic) when the next fetch will be done.
@property (strong) NSDate *checked; // The timestamp (seconds in epic) when last checked.
@property (strong) NSDate *success; // the last time it ran successfully.
@property (strong) NSString *period;
@property BOOL disabled;

@end

@implementation FTConnection

/*
 connectionId: The unique integer destination connection id number
 name: The user-readable name of the source connection.
 institutionId: The unique integer source institution id number
 username: The username for the source institution account.
 attempt: The timestamp (seconds in epic) when the next fetch will be done.
 success: The timestamp (seconds in epic) when the last successful fetch was done.
 checked: The timestamp (seconds in epic) when last checked.
 documentCount: The number of documents fetched the last time it ran successfully.
 fetchAll: True if the next fetch will force fetch of *all* documents, not just the new ones.
 info: A string to display to the user. Used to be more specific about what might be wrong.
 state: The connection state. Can be one of:
 "created"  Transitional state when connection has just been created
 "waiting"  Idle state. Waiting for the "attempt" date to be reached
 "connecting"  The fetcher is attempting to connect to the source.
 "uploading"  The fetcher is actively fetching documents.
 "question"  A question has been posed that the client must answer before fetching can proceed.
 "answered"  The client has answered the question. Transitional state until the server tries to fetch again.
 "manual"  I'll get you more info about this
 "disabled" and this
 "incorrect" and this
 "error"  The fetch has failed. Client should show an error string based on the "state" and "info" fields
 */

- (id) initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _key = dictionary[@"id"];
        self.session = [FTSession sharedSession];
        self.connectionId = [_key longValue];
        self.name = dictionary[@"name"];
        self.institutionId = [(NSNumber *)dictionary[@"institutionId"] longValue];
        self.username = dictionary[@"username"];
        self.period = dictionary[@"period"];
        self.info = dictionary[@"info"];
        self.fetchAll = [dictionary[@"fetchAll"] boolValue];
        self.originalValues = @{@"name" : self.name,
                                @"username" : self.username,
                                @"password" : [NSNull null],
                                @"fetchAll" : @(self.fetchAll) };
        self.stateString = dictionary[@"state"];
        self.state = [self stateFromString:self.stateString];
        self.documentCount = [dictionary[@"documentCount"] longValue];
        self.attempt = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"attempt"] longValue]];
        self.checked = [NSDate dateWithTimeIntervalSince1970: [dictionary[@"checked"] longValue]];
        self.success = [NSDate dateWithTimeIntervalSince1970: [dictionary[@"success"] longValue]];
    }
    return self;
}

- (void)dealloc {
    self.connectionId = 0;
    self.session = nil;
    self.institutionId = 0;
    self.documentCount = 0;
    self.fetchAll = 0;
    self.state = 0;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ id=%ld %@ (%@) %@ %@",
            [super description], self.connectionId, self.name, self.stateString, self.detailedText,self.info];
}

/*
 sample dictionary:
 (NSDictionary *) $1 = 0x10f88ad0 {
     attempt = 1355606678;
     checked = "-57600";
     documentCount = 0;
     enabled = 1;
     fetchAll = 0;
     id = 2182;
     info = "";
     institutionId = 4;
     name = "Bank of America";
     period = 1w;
     retries = 0;
     state = uploading;
     success = 1260307214;
     username = drewmwilson;
 }
*/

- (BOOL)boolFromInt:(int)i
{
    return i == 0 ? false : true;
}

- (BOOL)updateWithDictionary:(NSDictionary *)dictionary {
    // assumes the following are immutable: connection id, institution id
    BOOL updated = NO;
    if (![self.name isEqualToString:dictionary[@"name"]]) {
        self.name = dictionary[@"name"];
        updated = YES;
    }
    if (![self.username isEqualToString:dictionary[@"username"]]) {
        self.username = dictionary[@"username"];
        updated = YES;
    }
    if (![self.stateString isEqualToString:dictionary[@"state"]]) {
        self.stateString = dictionary[@"state"];
        self.state = [self stateFromString:self.stateString];
        updated = YES;
    }
    if (![self.info isEqualToString:dictionary[@"info"]]) {
        self.info = dictionary[@"info"];
        updated = YES;
    }
    long count = [dictionary[@"documentCount"] longValue];
    if (self.documentCount != count) {
        self.documentCount = count;
        updated = YES;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"attempt"] longValue]];
    if (![self.attempt isEqualToDate:date]) {
        self.attempt = date;
        updated = YES;
    }
    date = [NSDate dateWithTimeIntervalSince1970: [dictionary[@"checked"] longValue]];
    if (![self.checked isEqualToDate:date]) {
        self.checked = date;
        updated = YES;
    }
    date = [NSDate dateWithTimeIntervalSince1970: [dictionary[@"success"] longValue]];
    if (![self.success isEqualToDate:date]) {
        self.success = date;
        updated = YES;
    }
    self.fetchAll = [(NSNumber *)dictionary[@"fetchAll"] boolValue];
    
    return updated;
}

- (FTConnectionState) stateFromString:(NSString *)string
{
    if ([string isEqualToString:WORKFLOW_STATE_CREATED])
        return created;
    else if ([string isEqualToString:WORKFLOW_STATE_WAITING])
        return waiting;
    else if ([string isEqualToString:WORKFLOW_STATE_CONNECTING])
        return connecting;
    else if ([string isEqualToString:WORKFLOW_STATE_UPLOADING])
        return uploading;
    else if ([string isEqualToString:WORKFLOW_STATE_QUESTION])
        return question;
    else if ([string isEqualToString:WORKFLOW_STATE_ANSWERED])
        return answered;
    else if ([string isEqualToString:WORKFLOW_STATE_MANUAL])
        return manual;
    else if ([string isEqualToString:WORKFLOW_STATE_DISABLED])
        return disabled;
    else if ([string isEqualToString:WORKFLOW_STATE_INCORRECT])
        return incorrect;
    else if ([string isEqualToString:WORKFLOW_STATE_ERROR])
        return error;

    NSAssert(false, @"Unknown ConnectionStatus:%@", string);
    
    return error;
}

- (NSString *) stringFromState:(FTConnectionState) connectionState
{
    switch (connectionState) {
        case created:
            return WORKFLOW_STATE_CREATED;
        case waiting:
            return WORKFLOW_STATE_WAITING;
        case connecting:
            return WORKFLOW_STATE_CONNECTING;
        case uploading:
            return WORKFLOW_STATE_UPLOADING;
        case question:
            return WORKFLOW_STATE_QUESTION;
        case answered:
            return WORKFLOW_STATE_ANSWERED;
        case manual:
            return WORKFLOW_STATE_MANUAL;
        case disabled:
            return WORKFLOW_STATE_DISABLED;
        case incorrect:
            return WORKFLOW_STATE_INCORRECT;
        case error:
            return WORKFLOW_STATE_ERROR;
        default:
            NSLog(@"Unknown state? %d", connectionState);
    }
    
    NSAssert(false, @"Unknown ConnectionStatus:%d", connectionState);
}

- (NSString *)label {
    return self.name;
}

- (NSString *)detailedText
{
    if (self.disabled)
        return NSLocalizedString(@"Institution temporarily disabled", @"institution temporarily disabled string");
    switch (self.state) {
        case created:
        case answered:
        case manual:
            return NSLocalizedString(@"Contacting institution…", @"");
            break;
        case waiting:
        {
            static NSDateFormatter *dateFormatter = nil;
            if (dateFormatter == nil) {
                NSDateFormatterStyle dateFormat =
                    UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ?
                        NSDateFormatterFullStyle : NSDateFormatterShortStyle;
                dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateStyle:dateFormat];
            }
            NSString *dateString = [dateFormatter stringFromDate:self.checked];
            if (self.documentCount != 0) {
                return [NSString stringWithFormat:@"Fetched %ld documents on %@", self.documentCount, dateString];
            } else {
                if ([self.checked timeIntervalSince1970] > 0)
                    return [NSString stringWithFormat:@"Checked for documents on %@", dateString];
                else
                    return @"Last fetch did not complete. We will try again later.";
            }
            break;
        }
        case connecting:
            return NSLocalizedString(@"Establishing secure connection…", @"");
            break;
        case uploading:
            if (self.documentCount != 0)
                return [NSString stringWithFormat:@"Fetching documents… %ld fetched.", self.documentCount];
            else
                return [NSString stringWithFormat:@"Fetching documents…"];
            break;
        case question:
            return NSLocalizedString(@"Requires attention", @"");
            break;
        case disabled:  // shouldn't get here...
            return NSLocalizedString(@"Disabled", @"");
            break;
        // The fetch has failed. Client should show an error string based on the "state" and "info" fields
        case error:
            return NSLocalizedString(@"Has an error", @"");
            break;
        case incorrect: // I'll get you more info about this
            return NSLocalizedString(@"Working…", @"");
        default:
            ;
    }

    return [NSString stringWithFormat:@"TODO: implement support for %@", [self stringFromState:self.state]];
}

- (NSString *)getInfoDescription {
    return self.info;
}

- (NSURL *)iconURL
{
    if (_iconURL == nil)
        [self checkInstitution];
    return _iconURL;
}

- (NSString *)formatDateForSettings:(NSDate *)date {
    static NSDateFormatter *_dayFormatter = nil;
    if (_dayFormatter == nil) {
        _dayFormatter = [[NSDateFormatter alloc] init];
        // NSDateFormatterLongStyle NSDateFormatterFullStyle NSDateFormatterMediumStyle 
        [_dayFormatter setDateStyle:NSDateFormatterLongStyle];
        [_dayFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    return [_dayFormatter stringFromDate:date];
}

- (NSString *)lastChecked {
    return [self formatDateForSettings:self.checked];
}

- (NSString *)lastFetched {
    return [self formatDateForSettings:self.success];
}

- (NSString *)fetchFrequency {
    if ([self.period isEqualToString:@"1w"])
        return @"Week";
    else    if ([self.period isEqualToString:@"1d"])
        return @"Day";
    else if ([self.period isEqualToString:@"1m"])
        return @"Month";
    else
        return self.period;
}

- (BOOL) hasIssues {
    return self.state == question || self.state == error;
}

- (BOOL) hasError {
    return self.state == error;
}

- (BOOL) hasQuestion {
    return self.state == question;
}

- (BOOL) isTransitioning {
    if (self.isDisabled)
        return NO;
    
    switch (self.state) {
        case waiting:
        case question: // A question has been posed that the client must answer before fetching can proceed.
        case disabled: // and this
        case incorrect: // and this
        case error: // The fetch has failed. Client should show an error string based on the "state" and "info" fields
            return NO;
        case answered: // The client has answered the question. Transitional state until the server tries to fetch again.
        case manual: // I'll get you more info about this
        case created: // Transitional state when connection has just been created
        case connecting: // The fetcher is attempting to connect to the source.
        case uploading: // The fetcher is actively fetching documents
            return YES;
    }
    return YES;
}

- (void)checkInstitution
{
    if (self.institution)
        return;
    self.institution = [[FTSession sharedSession] institutionWithId:self.institutionId];
    //NSAssert(self.institution != nil, @"nil institutions for %ld, connectionId %ld", self.institutionId, self.connectionId);
    if (self.institution) {
        self.disabled = ![self.institution enabled];
        if (!self.disabled)
            self.disabled = self.state == disabled;
        _iconURL = self.institution.logoURL;
    }
}

-(BOOL)isDisabled {
    [self checkInstitution];
    return self.disabled;
}

/*
 Operation: conndelete
 Purpose: Deletes given document destination connection(s)
 URL parameters:
 id or ids  (The unique integer destination id number, or a comma-separated list of such id's)
 json
 ticket
 Response: None. The request either succeeds or fails.
 */
- (BOOL)destroy {
    NSDictionary *params = @{@"id":@(self.connectionId)};
    NSURLRequest *r = [[FTSession sharedSession] requestForOperand:FTDeleteConnection
                    withParams:params];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:r success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"deleted %@", self);
        [[NSNotificationCenter defaultCenter] postNotificationName:FTConnectionDeleted object:self userInfo:nil];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@ request failed because %@", request, error);
        if (error.code == DOMAIN_ERROR_CODE) {
            [[FTSession sharedSession] handleError:error forResponse:response withTitle:@""];
        } else {
            [CommonLayout showWarningAlert:error.localizedDescription errorMessage:nil delegate:nil];
        }
    }];
    [[FTSession sharedSession] enqueueHTTPRequestOperation:op];
    return NO;
}

- (void)refetch {
    NSDictionary *params = @{@"ids":@(self.connectionId)};
    NSURLRequest *r = [[FTSession sharedSession] requestForOperand:FTRefreshConnection
                        withParams:params];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:r success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [[FTSession sharedSession] requestConnectionsList];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSString *title = NSLocalizedString(@"Cannot Refresh Connection", nil);
        [[FTSession sharedSession] handleError:error forResponse:response withTitle:title];
    }];
    [[FTSession sharedSession] enqueueHTTPRequestOperation:op];
}

- (NSDictionary *)deltaValues:(NSDictionary *)values {
    NSMutableDictionary *delta = [NSMutableDictionary dictionaryWithCapacity:self.originalValues.count];
    [self.originalValues enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![obj isEqual:values[key]]) {
            delta[key] = values[key];
        }
    }];
    return delta;
}

#pragma mark save

// Write settings to server
- (void)save {
    // NOTE: doesn't work as JSON - have to convert to XML
    // returns :{"errorType":"com.filethis.common.exception.FTException","errorMessage":"Failed to read incoming XML Document\n"}
    NSMutableDictionary *delta = [@{} mutableCopy];
    if (self.name && ![self.name isEqualToString:self.originalValues[@"name"]])
        delta[@"name"] = self.name;
    if (self.username && ![self.username isEqualToString:self.originalValues[@"username"]])
        delta[@"username"] = self.username;
    if (self.password && ![self.password isEqualToString:self.originalValues[@"password"]])
        delta[@"password"] = self.password;
//    BOOL originalFetchAll = booleanValue(self.originalValues[@"fetchAll"]);
    if (self.fetchAll)
        delta[@"fetchAll"] = @"true";
    if ([delta count] > 0) {

        UpdateConnectionOperation *op = [[UpdateConnectionOperation alloc] initForConnection:self withChanges:delta];
        [[FTSession sharedSession] enqueueHTTPRequestOperation:op];
        [[NSNotificationCenter defaultCenter] postNotificationName:FTUpdateConnection object:self];
    }
}

- (void)addQuestion:(FTQuestion *)question {    
    if (self.questions != nil) {
        for (FTQuestion *q in self.questions) {
            if (q.uniqueId == question.uniqueId &&
                [q.key isEqualToString: question.key] &&
                q.connectionId == question.connectionId)
                return;
        }
        [self.questions addObject:question];
    } else {
        self.questions = [NSMutableArray arrayWithObject:question];
    }
}

- (void)answeredEverything {
    (void) [self updateWithDictionary:@{@"state" : @"answered"}];
    [self.questions removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:FTUpdateConnection object:self userInfo:nil];
}

//- (NSArray *)updateSettingsSource:(NSArray *)originalDataSource withValues:(NSDictionary *)keyValues {
//    NSMutableArray *dataStore = [[NSMutableArray alloc] initWithArray:originalDataSource copyItems:YES];
//    
//    for (id section in dataStore) {
//        for (id row in section) {
//            NSDictionary *dictionary = row;
//            IASKSpecifier *specifier;
//            BOOL isSpecifier = [row isMemberOfClass:[IASKSpecifier class]];
//            NSString *key;
//            if (isSpecifier) {
//                specifier = row;
//                dictionary = specifier.specifierDict;
//            }
//            key = dictionary[@"Key"];
//            if (keyValues[key] != nil) {
//                if (isSpecifier) {
//                    NSMutableDictionary *temp =
//                    [NSMutableDictionary dictionaryWithDictionary:dictionary];
//                    temp[kIASKDefaultValue] = keyValues[key];
//                    specifier.specifierDict = [NSDictionary dictionaryWithDictionary:temp];
//                } else {
//                    ((NSMutableDictionary *)dictionary)[kIASKDefaultValue] = keyValues[key];
//                }
//            }
//        }
//    }
//    
//    return dataStore;
//}
//
//-(NSArray *)updateSettingsDataSource:(NSArray *)originalDataSource {
//    FTInstitution *institution = [[FTSession sharedSession] institutionWithId:self.institutionId];
//    NSDictionary *keyValues = @{@"nickname" : self.name,
//                                @"username" : self.username,
//                                @"last_checked" : self.lastChecked,
//                                @"last_fetched" : self.lastFetched,
//                    //         @"refetch" : self.fetchAgain,
//                                @"fetch_frequency" : self.fetchFrequency,
//                                @"status" : self.detailedText,
//                                @"institution_name" : institution.name,
//                                @"institution_type" : institution.type,
//                                @"document_count" : @(self.documentCount)
//                                };
//    NSLog(@"print dataSource:%@", originalDataSource);
//    
//    NSArray *dataSource = [self updateSettingsSource:originalDataSource withValues:keyValues];
//    
//    return dataSource;
//}
//

// POST /ftapi/ftapi?op=questionanswer&id=481&flex=true&ticket=Lv4jJZpf2yt0XP5jMg1mTiFRREn HTTP/1.1
// response: <result></result>
/*
 POST /ftapi/ftapi?op=questionanswer&id=481&flex=true&ticket=Lv4jJZpf2yt0XP5jMg1mTiFRREn HTTP/1.1
 Host: staging.filethis.com
 Connection: keep-alive
 Content-Length: 118
 Origin: https://staging.filethis.com
 User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.16 (KHTML, like Gecko) Chrome/24.0.1306.0 Safari/537.16
 Content-Type: application/json
 Accept: * / *
Referer: https://staging.filethis.com/client/Main-0.5.swf
Accept-Encoding: gzip,deflate,sdch
Accept-Language: en-US,en;q=0.8
Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.3
Cookie: __utma=68377350.83118826.1337242804.1346968713.1347053522.20; __utmc=68377350; __utmz=68377350.1337242804.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); __utma=204825298.1201723894.1345771794.1348899320.1348938510.22; __utmc=204825298; __utmz=204825298.1345771794.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none)

[{"key": "In what city was your high school? (Enter only \"Charlotte\" for Charlotte High School)", "value": "Sitka"}]*/

/*
 -(NSString *)getUIStringForConnectionState:(NSString *)state {
 NSString *uiString = nil;
 
 if ([state isEqualToString:WORKFLOW_STATE_CREATED] ||
 [state isEqualToString:WORKFLOW_STATE_ANSWERED] ||
 [state isEqualToString:WORKFLOW_STATE_MANUAL])
 //        case SourceConnectionVO.CREATED_STATE:
 //        case SourceConnectionVO.ANSWERED_STATE:
 //        case SourceConnectionVO.MANUAL_STATE:
 uiString = @"Contacting institution...";
 else 
 break;
 case SourceConnectionVO.CONNECTING_STATE:
 subtextString = "Establishing secure connection...";
 break;
 case SourceConnectionVO.INCORRECT_STATE:
 subtextString = "Working...";
 break;
 case SourceConnectionVO.UPLOADING_STATE:
 subtextString = "Fetching documents...  ";
 if (connection.documentCount > 0)
 subtextString += connection.documentCount.toString() + " fetched";
 break;
 case SourceConnectionVO.QUESTION_STATE:
 case SourceConnectionVO.ERROR_STATE:
    subtextString = "Requires attention";
    break;
 }
 
 }
 
*/


/*

 Hi Drew,
 
 Here's a code snippet from the Flex client that shows the enumeration of the question types:
 
 public static const SIMPLE_TYPE:String = "simple";
 public static const COMPLEX_TYPE:String = "complex";
 public static const CREDENTIALS_TYPE:String = "credentials";
 public static const TWO_LETTER_STATE_TYPE:String = "two_letter_state";
 public static const BRANCH_CODE_TYPE:String = "branch_code";
 public static const PIN_TYPE:String = "pin";
 public static const ACCOUNT_TYPE_NOT_SUPPORTED_TYPE:String = "not_supported";
 public static const NOT_PAPERLESS_TYPE:String = "not_paperless";
 public static const USER_IS_LOCKED_OUT_TYPE:String = "user_locked_out";
 public static const USER_MUST_SET_UP_ACCOUNT_TYPE:String = "user_must_set_up_account";
 public static const TYPE_USER_ACTION_REQUIRED:String = "user_action_required";
 public static const GENERAL_SECURITY_PROBLEM_TYPE:String = "general_security_problem";
 
 As you can see in the question list you've gotten back from the server, there can be more than one question pending. We just pose each of them in turn until the user answers them all, sending "questionanswer" requests for each answer the user gives you. It's kind of strange that your connection has so many of them, but I guess they've accumulated.
 
 I'll describe the question types one by one.
 
 Looking at these, it seems strange to me that we use "pin" as the "key" value in the answers for several of the question types. That's odd, but it's what I see in the code. I'll ask Jim about this.
 
 
 simple
 
 This type of question has a "data" property whose value is the text of a question to pose to the user. Use this as your prompt text.
 
 Provide a simple text field into which the user can type his answer.
 
 The answer string (sent by your subsequent "questionanswer" request) should be of the form:
 
 {"key": "pin", "value": "<answer>"}
 
 where <answer> is what the user entered.
 
 
 complex
 
 Let's leave this one for later. Ping me again, when you've got the other question types done.
 
 
 credentials
 
 This type of question has no "data" property.
 
 You can use the prompt text:
 
 Please enter your credentials
 
 You need to present the user with username and password fields.
 
 The answer string should be JSON of the form:
 
 {"key": "credentials", "value": "<encoded_credentials>"}
 
 where <encoded_credentials> is the base-64 encoding of the string:
 
 <username>:<password>
 
 where <username> and <password> are what the user entered in your dialog.
 
 
 two_letter_state
 
 This type of question has no "data" property.
 
 You can use the prompt text:
 
 Please select your state
 
 and present a popup/spinner that has all the US states (with full names).
 
 The answer string should be of the form:
 
 {"key": "state", "value": "<two_letter_state>"}
 
 where <two_letter_state> is the uppercase two-letter abbreviation for the chosen state.
 
 Note: If you'd like a page of text that has mappings from the abbreviations to the full names, let me know and I'll send it to you.
 
 
 branch_code
 
 This type of question has no "data" property.
 
 You can use the prompt text:
 
 Please enter your branch code
 
 and provide a simple text field into which the user can type his answer.
 
 The answer string should be of the form:
 
 {"key": "pin", "value": "<branch_code>"}
 
 where <branch_code> is what the user entered.
 
 
 pin
 
 This type of question has no "data" property.
 
 You can use the prompt text:
 
 Please enter your PIN
 
 and provide a simple text field into which the user can type his answer.
 
 The answer string should be of the form:
 
 {"key": "pin", "value": "<pin>"}
 
 where <pin> is what the user entered.
 
 
 not_supported
 
 Does not require an answer.
 
 Display the string:
 
 FileThis currently does not support this type of account for this institution.
 
 
 not_paperless
 
 Does not require an answer.
 
 Display the string:
 
 Before we can retrieve your documents, you need to log in to your account directly from your browser and sign up to "go paperless."
 
 
 user_locked_out
 
 Does not require an answer.
 
 Display the string:
 
 Your account is locked. Please log into your account directly to unlock it.
 
 
 user_must_set_up_account
 
 Does not require an answer.
 
 Display the string:
 
 You must set up your account profile. Please log into your account directly to do so.
 
 
 user_action_required
 
 Does not require an answer.
 
 Display the string:
 
 Please log into your account directly and respond to the question you are being asked there.
 
 
 general_security_problem
 
 Does not require an answer.
 
 Display the string:
 
 There is a general security problem in your account. Please log into your account directly to resolve it.
 
 
 That's a start at least.
 
 Let me know if you have more questions (I'm sure you will).
 
 Thanks,
 
 --Trent
 
 
 
 On Fri, Sep 7, 2012 at 3:33 PM, Drew Wilson <drewmwilson@mac.com> wrote:
 Hi Trent,
 
 I'm trying to implement the interactive question action, and I don't understand the response from the questionlist request.
 
 In my test, I'm trying to connect with Bank of America, and I get back this response:
 {
 "questions":
 [
 {"id":143,"data":"{\"questions\":[{\"key\":\"What was the name of your High School?\",\"label\":\"What was the name of your High School?\",\"persistent\":true,\"type\":\"text\"}]}","connectionId":225,"type":"complex","state":"pending"},
 
 {"id":287,"data":"{\"questions\":[{\"key\":\"What is the first name of your eldest sibling?\",\"label\":\"What is the first name of your eldest sibling?\",\"persistent\":true,\"type\":\"text\"}]}","connectionId":324,"type":"complex","state":"pending"},
 {"id":405,"connectionId":230,"type":"user_action_required","state":"pending"},
 {"id":441,"connectionId":198,"type":"user_locked_out","state":"pending"},
 {"id":450,"connectionId":197,"type":"credentials","state":"pending"},
 {"id":459,"connectionId":642,"type":"two_letter_state","state":"pending"}
 ]
 }
 
 
 Which of the question entries should I handle?
 
 Are the types predefined? e.g. is "two_letter_state" handled by this dialog?
 
 
 
 Thanks,
 
 Drew
 
 */


@end

@implementation UpdateConnectionOperation


/*
 <request>
 <connection>
 <name>American Express #2</name>
 <fetchAll>true</fetchAll>
 </connection>
 </request>
 */
- (NSString *)xmlFromDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *xmlSnippets = [NSMutableArray array];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key,id obj,BOOL *stop) {
        NSString *xmlSnippet;
        if ([obj isKindOfClass:[NSDictionary class]]) {
            obj = [self xmlFromDictionary:obj];
        } else if ([obj isKindOfClass:[NSArray class]]) {
            NSAssert(NO,@"cheap xml doesn't support arrays");
        }
        xmlSnippet = [NSString stringWithFormat:@"<%@>%@</%@>",key, obj, key];
        [xmlSnippets addObject:xmlSnippet];
    }];
    
    NSString *xml = [NSString stringWithFormat:@"<request><connection>%@</connection></request>",
                     [xmlSnippets componentsJoinedByString:@"\n"]];
    return xml;
}

/*
 
 https://staging.filethis.com/ftapi/ftapi?op=connupdate&id=2206&flex=true&ticket=bgQ2QZNnc9ZqMBNd0mYhhRu3vXo
 https://staging.filethis.com/ftapi/ftapi?op=connupdate&id=2206&flex=true&ticket=bgQ2QZNnc9ZqMBNd0mYhhRu3vXo
 Complete
 200 OK
 HTTP/1.1
 POST
 Yes
 text/xml
 /127.0.0.1
 staging.filethis.com/173.203.112.186
 
 <request>
 <connection>
 <name>American Express #2</name>
 <fetchAll>true</fetchAll>
 </connection>
 </request>
 
 response:
 <result>
 </result>
 
 then refetch connection list again...
 
 */

BOOL booleanValue(id value)
{
    if ([value respondsToSelector:@selector(boolValue)])
        return [value boolValue];
    
    if ([value respondsToSelector:@selector(isEqualToString:)] &&
        ([value isEqualToString:@"true"] || [value isEqualToString:@"1"]))
        return YES;
    
    return NO;
}

- (id)initForConnection:(FTConnection *)connection withChanges:(NSDictionary *)changes {
    NSString    *xmlString = [self xmlFromDictionary:changes];
    NSDictionary *params = @{ @"id" : @(connection.connectionId) };
    NSMutableURLRequest *request = [[FTSession sharedSession] createPostRequest:FTUpdateConnection withParameters:params withXml:xmlString];

    self = [super initWithRequest:request];
    if (self != nil) {
        [self setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [[FTSession sharedSession] requestConnectionsList];
            [[NSNotificationCenter defaultCenter] postNotificationName:FTUpdateConnection object:connection];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[FTSession sharedSession] handleError:error forOperation:operation withTitle:@"Cannot Save Data"];
        }];
    }
    return self;
}

@end


@interface ProcessConnectionsOperation () {
    BOOL _institutionsReady;
}

@property BOOL previousIsReady;
@property BOOL institutionsReady;

@end

@implementation ProcessConnectionsOperation

- (id)init {
    self = [super init];
    // Set up our sequenceNumber property.  Note that, because we can be called
    // from any thread, we have to use a lock to protect sSequenceNumber (that
    // is, to guarantee that each operation gets a unique sequence number).
    // In this case locking isn't a problem because we do very little within
    // that lock; there's no possibility of deadlock, and the chances of lock
    // contention are slight.
    if (self) {
        @synchronized ([ProcessConnectionsOperation class]) {
            static NSUInteger sSequenceNumber;
            self->_sequenceNumber = sSequenceNumber;
            sSequenceNumber += 1;
        }
        self.institutionsReady = [FTSession sharedSession].institutions != nil;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInstitutions:) name:FTListInstitutions object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL)isReady {
    BOOL r = [super isReady];
    r = r && self.json && self.institutionsReady;
    BOOL changing = _previousIsReady != r;
    if (changing)
        [self willChangeValueForKey:@"isReady"];
    _previousIsReady = r;
    if (changing)
        [self didChangeValueForKey:@"isReady"];
    return r;
}

- (void)setJson:(NSDictionary *)json {
    [self willChangeValueForKey:@"json"];
    [self willChangeValueForKey:@"isReady"];
    _json = [json copy];
    [self didChangeValueForKey:@"json"];
    [self didChangeValueForKey:@"isReady"];
}

-(BOOL)institutionsReady {
    return _institutionsReady;
}

- (void)setInstitutionsReady:(BOOL)institutionsReady {
    [self willChangeValueForKey:@"institutionsReady"];
    [self willChangeValueForKey:@"isReady"];
    _institutionsReady = institutionsReady;
    [self didChangeValueForKey:@"institutionsReady"];
    [self didChangeValueForKey:@"isReady"];
}

- (void)updateInstitutions:(NSNotification *)notification {
    self.institutionsReady = YES;
}

-(void)main{
    int numTransitioning = 0;
    int numWithQuestions = 0;
    int numUpdated = 0;
    int numAdded = 0;
    
    NSArray *rawConnections = self.json[@"connections"];
    NSMutableArray *connections;
//    NSLog(@"Processing %d raw connections", [rawConnections count]);
    
    if ([self isCancelled])
        return;
    
    if (self.oldConnections == nil || [self.oldConnections count] == 0) {
        // if no previous connections... save connections list
        numUpdated = [rawConnections count];
        connections = [NSMutableArray arrayWithCapacity:numUpdated];
        
        for (NSDictionary *konn in rawConnections) {
            
            if ([self isCancelled])
                return;
            
            FTConnection *c = [[FTConnection alloc] initWithDictionary:konn];
            if ([c isTransitioning]) {
                numTransitioning += 1;
//                NSLog(@"Transitioning connection: %@", c);
            }
            if (c.hasQuestion) {
                numWithQuestions += 1;
//                NSLog(@"Questioning connection: %@", c);
            }
            
            numAdded += 1;
            [connections addObject:c];
        }
    } else {
        // else - merge connection list into existing list
        connections = [self.oldConnections mutableCopy];
        
        NSMutableDictionary *connectionsMap = [[NSMutableDictionary alloc] init];
        for (FTConnection *connection in connections)
        {
            long connectionId = connection.connectionId;
            [connectionsMap setObject:connection forKey:[NSNumber numberWithLong:connectionId]];
        }
        
        for(NSDictionary *konnection in rawConnections) {
            
            if ([self isCancelled])
                return;
            
            id key = konnection[FT_CONNECTION_ID_KEY];
            FTConnection *c = connectionsMap[key];
            if (c != nil) {
                if ([c updateWithDictionary:konnection])
                    numUpdated += 1;
            } else {
                // new connection: create one and add to list
                numUpdated += 1;
                numAdded += 1;
                c = [[FTConnection alloc] initWithDictionary:konnection];
                [connections addObject:c];
            }
            
            if ([c isTransitioning]) {
                numTransitioning += 1;
//                NSLog(@"Transitioning connection: %@", c);
            }
            if (c.hasQuestion) {
                numWithQuestions += 1;
//                NSLog(@"Questioning connection: %@", c);
            }
        }
    }
    
    if (numAdded > 0) { // resort list
        [connections sortUsingComparator:^NSComparisonResult(FTConnection *c1, FTConnection *c2) {
            return [c1.name compare:c2.name];
        }];
    }
    
#ifdef ENABLE_NSLOG_REQUEST
    NSLog(@"Processed %d raw connections, %d updated, %d questions, %d transitioning", [rawConnections count], numUpdated, numWithQuestions, numTransitioning);
#endif

    if ([self isCancelled])
        return;
    
    // only assign connections if connections have changed or connections hasn't been set yet
    if (numUpdated != 0 || [FTSession sharedSession].connections == nil) {
        [FTSession sharedSession].connections = connections;
    }
    
    // post getConnections event
    [[NSNotificationCenter defaultCenter] postNotificationName:FTGotConnections object:connections userInfo:nil];
    
    // start downloading questions after we have all the connections
    if (numWithQuestions != 0) {
#ifdef ENABLE_NSLOG_REQUEST
        NSLog(@"requesting questions because %d questions", numWithQuestions);
#endif
        [[FTSession sharedSession] requestQuestions];
    }

    if (numTransitioning != 0 && !self.isCancelled) {
#ifdef ENABLE_NSLOG_REQUEST
        NSLog(@"reissuing connlist because %d still transitioning", numTransitioning);
#endif
        // We want UI to be responsive so delay shouldn't be too big...
        // but we don't want to overlap        
        double delayInSeconds = 5.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_after(popTime, q, ^(void){
            if (!self.isCancelled)
                [[FTSession sharedSession] requestConnectionsList];
        });
    }
}

@end
