//
//  ProfileDataManager.h
//  FileThis
//
//  Created by Manh nguyen on 1/3/14.
//
//

#import "BaseDataManager.h"

@interface ProfileDataManager : BaseDataManager

+ (ProfileDataManager *)getInstance;
- (NSArray *)getAllProfiles;

@end
