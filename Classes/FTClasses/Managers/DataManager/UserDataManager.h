//
//  UserDataManager.h
//  FileThis
//
//  Created by Cao Huu Loc on 1/20/14.
//
//

#import "BaseDataManager.h"

@interface UserDataManager : BaseDataManager

+ (UserDataManager*)getInstance;
- (NSDictionary*)updatePassword:(NSString*)oldPass withNewPassword:(NSString*)newPass;
- (NSDictionary*)getReferralInfo;

@end
