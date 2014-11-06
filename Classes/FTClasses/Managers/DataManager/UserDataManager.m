//
//  UserDataManager.m
//  FileThis
//
//  Created by Cao Huu Loc on 1/20/14.
//
//

#import "UserDataManager.h"
#import "UserService.h"

@interface BaseDataManager ()
@property (nonatomic, strong) NSMutableArray *allObjects;
@property (nonatomic, strong) NSMutableDictionary *findObjectByIdDictionary;
@end

@implementation UserDataManager

static UserDataManager *instance = nil;

+ (UserDataManager *)getInstance {
    @synchronized(self) {
        if (instance == nil) {
            instance = [[UserDataManager alloc] init];
        }
    }
    
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        // TODO
    }
    return self;
}

- (void)clearAll {
    [super clearAll];
}

- (id)getObjectByKey:(id)key {
    return nil;
}

- (NSDictionary*)updatePassword:(NSString*)oldPass withNewPassword:(NSString*)newPass
{
    UserService *service = [[UserService alloc] initUpdatePassword:oldPass newPassword:newPass];
    return [service sendRequestToServer];
}

- (NSDictionary*)getReferralInfo {
    UserService *service = [[UserService alloc] initGetReferralList];
    return [service sendRequestToServer];
}

@end
