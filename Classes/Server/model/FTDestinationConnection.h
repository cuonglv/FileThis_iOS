//
//  FTDestinationConnection.h
//  FileThis
//
//  Created by Drew Wilson on 1/6/13.
//
//

#import <Foundation/Foundation.h>

@interface FTDestinationConnection : NSObject

@property NSString *name;
@property NSUInteger destinationConnectionId;
@property NSUInteger destinationId;
@property (readonly) NSString *stateString;
@property (readonly) NSString *userString;
@property (readonly) NSString *statusString;
@property (readonly) NSString *errorDescription;

@property (readonly) BOOL needsAuthentication;
@property (readonly) BOOL needsRepair;

@property (nonatomic, strong) NSString *provider;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)launchApplication;
- (BOOL)canLaunchApplication;
- (BOOL)canLaunchToDocuments;

@end
