//
//  UserService.m
//  FileThis
//
//  Created by Cao Huu Loc on 1/20/14.
//
//

#import "UserService.h"
#import "CommonVar.h"
#import "NSString+XMLAdditions.h"

@implementation UserService

- (id)initUpdatePassword:(NSString*)oldPass newPassword:(NSString*)newPass
{
    self = [self initWithAction:kUserServiceActionUpdatePassword];
    if (self)
    {
        self.oldPassword = oldPass;
        self.updatePassword = newPass;
    }
    return self;
}

- (id)initGetReferralList {
    self = [self initWithAction:kUserServiceGetReferralList];
    if (self) {
    }
    return self;
}

- (id)initSendInvitationTo:(NSString*)email {
    self = [self initWithAction:kUserServiceSendInvitationMail];
    if (self) {
        self.invitationMail = email;
    }
    return self;
}

- (NSString *)serviceLink {
    if (self.action == kUserServiceActionUpdatePassword)
        return [NSString stringWithFormat:kURLUpdatePassword, [CommonVar ticket]];
    if (self.action == kUserServiceGetReferralList)
        return [NSString stringWithFormat:kURLGetReferralList, [CommonVar ticket]];
    if (self.action == kUserServiceSendInvitationMail)
        return [NSString stringWithFormat:kURLSendInvitation, [self.invitationMail urlEncode], [CommonVar ticket]];
    return nil;
}

- (NSString *)getHttpMethod {
    return @"POST";
}

- (NSMutableDictionary *)getHttpHeaders {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSData *postData = [[self getPostRequest] dataUsingEncoding:NSUTF8StringEncoding];
    [dict setValue:@"application/xml" forKey:@"Content-Type"];
    [dict setValue:[NSString stringWithFormat:@"%d", [postData length]] forKey:@"Content-Length"];
    return dict;
}

- (NSString *)getPostRequest {
    NSMutableString *postRequest = [[NSMutableString alloc] initWithCapacity:0];
    [postRequest appendString:@"<request>"];
    [postRequest appendString:@"<account>"];
    [postRequest appendString:@"<users>"];
    [postRequest appendString:@"<user>"];
    
    [postRequest appendFormat:@"<currentPassword>%@</currentPassword>", [self.oldPassword stringByEscapingCriticalXMLEntities]];
    [postRequest appendFormat:@"<password>%@</password>", [self.updatePassword stringByEscapingCriticalXMLEntities]];
    
    [postRequest appendString:@"</user>"];
    [postRequest appendString:@"</users>"];
    [postRequest appendString:@"</account>"];
    [postRequest appendString:@"</request>"];
    
    return postRequest;
}

@end
