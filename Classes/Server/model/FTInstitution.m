//
//  FTInstitution.m
//  FileThis
//
//  Created by Drew on 5/6/12.
//  Copyright (c) 2012 filethis.com. All rights reserved.
//

#import "UIKitExtensions.h"

#import "FTInstitution.h"
#import "FTSession.h"
#import "FTRequest.h"
#import "MF_Base64Additions.h"

NSString *FTInstitutionTypePopular = @"Popular";
NSString *FTInstitutionTypeLatest = @"New";
NSString *FTInstitutionTypeAll = @"All";
NSString *FTInstitutionTypeFinancial = @"Financial";
NSString *FTInstitutionTypeUtilities = @"Utilities";

static NSString *FTCreateConnection = @"connecttoinstitution";

@interface FTInstitution() {
    NSURL *_logoURL;
}

@property (getter = isPopular) bool popular;
@property (getter = isLatest) bool latest;

@end

@implementation FTInstitution

+ (UIImage *)placeholderImage
{
    return [UIImage imageNamed:@"glyphicons_263_bank"];
}

+ (UIImage *)disabledBadge
{
    return [UIImage imageNamed:@"disabled_badge"];
}


-(void)dealloc {

}

-(id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.name = dictionary[@"name"];
        _institutionId = [dictionary[@"id"] integerValue];
        self.logoName = dictionary[@"logo"];
        _type = [self displayNameForType:dictionary[@"type"]];
        self.popular = [dictionary[@"isPopular"] boolValue];
        self.latest = [dictionary[@"isNew"] boolValue];
        self.info = dictionary[@"info"];
        if (self.info.length == 0)
            self.info = nil;
        self.homePageAddress = dictionary[@"homePageUrl"];
        NSString *state = dictionary[@"state"];
        // known states: live, disa
        if ([state isEqualToString:@"live"])
            self.enabled = YES;
        else { // if ([state isEqualToString:INSTITUTION_STATE_DISABLED]) {
#ifdef DEBUG
            NSLog(@"Institution %@’s state = %@", self.name, state);
#endif
            self.enabled = NO;
        }
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%d) '%@'", [super description], self.institutionId,self.name];
}

- (NSString *)displayNameForType:(NSString *)type {
    if ([type isEqualToString:@"fina"]) {
        return @"Financial";
    } else if ([type isEqualToString:@"util" ]) {
        return @"Utilities";
    }
    return nil;
}

/*
 Operation: connecttoinstitution
 Purpose: To create a source connection to a source institution.
 URL parameters: id (the source institution id) json, ticket
 usernameencoded: The Base64-encoded username for the user's account at the institution
 passwordencoded: The Base64-encoded password for the user's account at the institution
 Response: Returns the unique id of the newly-created source connection on success.
 */
-(void)connectWithTicket:(NSString *)ticket withUsername:username withPassword:(NSString *)password
//-(void)createConnectionWithTicket:(NSString *)ticket withUser:(NSString *)username withPassword:(NSString *)password
{
    NSString *paramString = [NSString stringWithFormat:@"&id=%d&usernameencoded=%@&passwordencoded=%@",
                             self.institutionId, [username base64String], [password base64String]];
    FTRequest *request = [[FTRequest alloc] initWithTicket:ticket withVerb:FTCreateConnection withParameters:paramString];
    [request setReceiver:self withAction:@selector(createdConnection:)];
    NSLog(@"CONNECT %@/%@ TO %@, request:%@", username, password, self.name, request);
    [request start];
}

- (void)createdConnection:(FTRequest *)request {
    if (request.errorType) {
        if ([request.errorType isEqualToString:FTPremiumFeatureException]) {
            NSNotification *notification = [NSNotification notificationWithName:FTPremiumFeatureException object:request.json];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        } else {
            NSLog(@"Cannot create new connection because %@", request.json);
            [[NSNotificationCenter defaultCenter] postNotificationName:FTCreateConnectionFailed object:nil userInfo:request.json];
            
//            NSString *message = request.errorMessage;
//            NSString *title = @"Cannot Add Connection";
//            [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    } else {
        NSLog(@"created new connection. %@", request);
        [[FTSession sharedSession] requestConnectionsList];
    }
}

- (BOOL)matchesType:(NSString *)typeName {
    if ([typeName isEqualToString:FTInstitutionTypePopular])
        return self.isPopular;
    else if ([typeName isEqualToString:FTInstitutionTypeLatest])
        return self.isLatest;
    else if ([typeName isEqualToString:FTInstitutionTypeAll])
        return YES;
    else
        return [typeName isEqualToString:self.type];
}

- (BOOL)matchesByName:(NSString *)partialName {
    if (partialName == nil || [partialName length] == 0 ||
        ([self.name compare:partialName
                    options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
                      range:NSMakeRange(0, [partialName length])] == NSOrderedSame)) {
        return YES;
    }
    return NO;
}

- (NSURL *)logoURL
{
    if (_logoURL == nil) {
        _logoURL = [NSURL URLWithString:self.logoName relativeToURL:[FTSession logosURL]];
    }
    return _logoURL;
}

@end

@implementation ProcessInstitutionsOperation

-(void)setJson:(id)json {
    [self willChangeValueForKey:@"json"];
    _json = json;
    [self didChangeValueForKey:@"json"];
}

- (BOOL)isReady {
    BOOL r = [super isReady];
    r = r && self.json != nil;
    return r;
}

-(void)main {
    NSAssert(self.json, @"json received");
    [self.class processInstitutions:self.json[@"institutions"]];
}

+ (void)processInstitutions:(NSArray *)rawInstitutions {
    NSAssert1([rawInstitutions count] != 0, @"institutions is nil? %@", rawInstitutions);
    NSArray *sortedData = [rawInstitutions sortedArrayUsingComparator:
                           (NSComparator)^(id obj1, id obj2) {
                               NSString *name1 = [obj1 valueForKey:@"name"];
                               NSString *name2 = [obj2 valueForKey:@"name"];
                               return [name1 caseInsensitiveCompare:name2]; }];
    NSAssert1([sortedData count] != 0, @"sorted data is nil? %@", sortedData);
    NSMutableArray  *institutions = [[NSMutableArray alloc] initWithCapacity:[sortedData count]];
    for (NSDictionary *data in sortedData) {
        FTInstitution *i = [[FTInstitution alloc] initWithDictionary:data];
//        if (i.enabled)
            [institutions addObject:i];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FTUpdateInstitutions object:institutions];
}

@end

