//
//  FTInstitution.h
//  FileThis
//
//  Created by Drew on 5/6/12.
//  Copyright (c) 2012 filethis.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 
 
 Operation: institutionlist
 Purpose: Returns a list of all document source institutions. There are several dozens of these, so far.
 URL parameters: json, ticket
 Response: A list of the source institutions, each with the following properties:
 id: The unique integer source institutions id number
 type: "find" for financial, "util" for utilities,    
 name: The user-readable name of the source institution.
 state: "live" if the the server is currently able to fetch from the institution. "hold", if there's a problem we're working on. In the web client, we overlay the text "Currently Unavailable" and disable choosing it for new connections.
 homePageUrl: The user-readable URL of the site. Informational only.
 phone: The user-readable phone number for the institution. Informational only.
 logoPath: The relative path for the source institution logo
 logo: the name of the institution's png icon
 
 */

extern NSString *FTInstitutionTypePopular;
extern NSString *FTInstitutionTypeLatest;
extern NSString *FTInstitutionTypeAll;
extern NSString *FTInstitutionTypeFinancial;
extern NSString *FTInstitutionTypeUtilities;

@interface FTInstitution : NSObject

@property (nonatomic, strong) NSString *name;
@property NSInteger institutionId;
@property (nonatomic, readonly, strong) NSString *type;
@property (nonatomic, readonly) NSURL *logoURL;
@property (nonatomic, strong) NSString *info;
@property (nonatomic, strong) NSString *homePageAddress;
@property (nonatomic, strong) NSString *logoName;
@property BOOL enabled;

-(id)initWithDictionary:(NSDictionary *)dictionary;

-(void)connectWithTicket:(NSString *)ticket withUsername:username withPassword:(NSString *)password;

- (BOOL)matchesType:(NSString *)typeName;
- (BOOL)matchesByName:(NSString *)partialName;
+ (UIImage *)placeholderImage;
+ (UIImage *)disabledBadge;

@end

@interface ProcessInstitutionsOperation : NSOperation

@property (nonatomic, copy) id json;
+ (void)processInstitutions:(NSArray *)rawInstitutions;

@end
