//
//  FTAccount.h
//  FileThis
//
//  Created by Drew on 5/6/12.
//  Copyright (c) 2012 filethis.com. All rights reserved.
//

/*
 
    An account represents a user's relationship with an institution.
 
*/


#import <Foundation/Foundation.h>

/*
 id: The unique integer destination connection id number
 name: The user-readable name of the source connection.
 institutionId: The unique integer source institution id number
 username: The username for the source institution account.
 attempt: The timestamp (seconds in epic) when the next fetch will be done.
 success: The timestamp (seconds in epic) when the last successful fetch was done.
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
@interface FTAccount : NSObject

@property long id; // The unique integer destination connection id number
@property (retain) NSString *name; // The user-readable name of the source connection.
@property long institutionId; // The unique integer source institution id number
@property (retain) NSString *username; // The username for the source institution account.
@property long attempt; //: The timestamp (seconds in epic) when the next fetch will be done.
@property long success; // The timestamp (seconds in epic) when the last successful fetch was done.
@property long documentCount; // The number of documents fetched the last time it ran successfully.
@property BOOL fetchAll; // True if the next fetch will force fetch of *all* documents, not just the new ones.
@property (retain) NSString *info; //: A string to display to the user. Used to be more specific about what might be wrong.
@property (retain) NSString *state; // :

@end
