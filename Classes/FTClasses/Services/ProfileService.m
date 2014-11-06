//
//  ProfileService.m
//  FileThis
//
//  Created by Manh nguyen on 1/3/14.
//
//

#import "ProfileService.h"
#import "CommonVar.h"

@implementation ProfileService

- (NSString *)serviceLink {
    if (self.action == kActionGetAllProfiles) {
        return [NSString stringWithFormat:kUrlGetAllProfilesLink, [CommonVar ticket]];
    }
    
    return nil;
}

@end
