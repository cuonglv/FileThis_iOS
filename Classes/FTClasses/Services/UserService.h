//
//  UserService.h
//  FileThis
//
//  Created by Cao Huu Loc on 1/20/14.
//
//

#import "BaseService.h"

#define kURLUpdatePassword          @"compact=true&json=true&op=accountupdate&flex=true&ticket=%@"
#define kURLGetReferralList         @"compact=true&json=true&op=reflist&flex=true&ticket=%@"
#define kURLSendInvitation          @"compact=true&json=true&op=refer&flex=true&email=%@&ticket=%@"

#define kUserServiceActionUpdatePassword    0
#define kUserServiceGetReferralList         1
#define kUserServiceSendInvitationMail      2

@interface UserService : BaseService

@property (nonatomic, copy) NSString *oldPassword;
@property (nonatomic, copy) NSString *updatePassword;
@property (nonatomic, copy) NSString *invitationMail;

- (id)initUpdatePassword:(NSString*)oldPass newPassword:(NSString*)newPass;
- (id)initGetReferralList;
- (id)initSendInvitationTo:(NSString*)email;

@end
