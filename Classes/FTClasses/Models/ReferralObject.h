//
//  ReferralObject.h
//  FileThis
//
//  Created by Cao Huu Loc on 5/23/14.
//
//

#import "BaseObject.h"

@interface ReferralObject : BaseObject
@property (nonatomic, copy) NSString *refereeEmail;
@property (nonatomic, strong) NSNumber *state;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSNumber *sourceConnectionQuota;
@property (nonatomic, strong) NSNumber *storageQuota; //bytes (NOT KB)
@property (nonatomic, strong) NSNumber *expires;

@end
