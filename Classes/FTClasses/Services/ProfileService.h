//
//  ProfileService.h
//  FileThis
//
//  Created by Manh nguyen on 1/3/14.
//
//

#import "BaseService.h"

#define kUrlGetAllProfilesLink  @"compact=true&json=true&op=profilelist&ticket=%@"

// Cabinet Actions
#define kActionGetAllProfiles   0

@interface ProfileService : BaseService

@end
