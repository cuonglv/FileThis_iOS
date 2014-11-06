/*
    FTConnection.h
    FileThis

    Created by Drew on 5/6/12.
    Copyright (c) 2012 filethis.com. All rights reserved.

    A connection represents a user's relationship with an institution.
 
*/

#import <Foundation/Foundation.h>
#import "FTQuestion.h"

@interface FTConnection : NSObject

@property (readonly) id key;
@property long connectionId; // The unique integer destination connection id number
@property long institutionId; // The unique integer source institution id number
@property (strong) NSMutableArray *questions;
@property (strong) NSString *name; // The user-readable name of the source connection.
@property (strong) NSString *username; // The username for the source institution account.
@property (readonly) NSString *lastChecked;
@property (readonly) NSString *lastFetched;
@property (readonly) NSString *fetchFrequency;
@property (readonly) NSURL *iconURL;
@property NSString *password;
@property (strong) NSString *info; //: A string to display to the user. Used to be more specific about what might be wrong.

@property long documentCount; // The number of documents fetched the last time it ran successfully.
@property BOOL fetchAll; // True if the next fetch will force fetch of *all* documents, not just the new ones.

- (id)initWithDictionary:(NSDictionary *)attributes;
- (BOOL)updateWithDictionary:(NSDictionary *)dictionary;

- (NSString *)label;
- (NSString *)detailedText;
- (NSString *)getInfoDescription;
//- (UIImage *)icon;

- (BOOL)hasQuestion;
- (BOOL)hasError;
- (BOOL)hasIssues;
- (BOOL)isTransitioning;
- (BOOL)isDisabled;

- (BOOL)destroy;
- (void)refetch;
- (void)save;

- (void)addQuestion:(FTQuestion *)question;
- (void)answeredEverything;

@end

@interface ProcessConnectionsOperation : NSOperation

@property (copy, nonatomic) NSDictionary *json;
@property (copy, nonatomic) NSArray *oldConnections;
@property NSUInteger sequenceNumber;

@end

extern NSString *FT_CONNECTION_ID_KEY;
