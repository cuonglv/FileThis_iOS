//
//  ProfileDataManager.m
//  FileThis
//
//  Created by Manh nguyen on 1/3/14.
//
//

#import "ProfileDataManager.h"
#import "ProfileService.h"
#import "ProfileObject.h"
#import "CommonLayout.h"

@interface BaseDataManager ()
@property (nonatomic, strong) NSMutableArray *allObjects;
@property (nonatomic, strong) NSMutableDictionary *findObjectByIdDictionary;
@end

@implementation ProfileDataManager

static ProfileDataManager *instance = nil;

+ (ProfileDataManager *)getInstance {
    @synchronized(self) {
        if (instance == nil) {
            instance = [[ProfileDataManager alloc] init];
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

- (NSArray *)getAllProfiles {
    if (self.allObjects != nil) {
        return [self getAllObjects];
    }
    
    [self reloadAll];
    return [self getAllObjects];
}

- (void)reloadAll {
    @synchronized(self) {
        ProfileService *service = [[ProfileService alloc] initWithAction:kActionGetAllProfiles];
        NSError *error;
        id dataResponse = [service sendRequestToServer:&error];
        if (dataResponse) {
            self.allObjects = [self parseDataToObjects:dataResponse];
        } else {
            /*dispatch_async(dispatch_get_main_queue(), ^{
             [CommonLayout showWarningAlert:NSLocalizedString(@"ID_WARNING_CANNOT_LOAD_ACCOUNT_LIST", @"") errorMessage:[error localizedDescription] delegate:nil];
             });*/
        }
    }
}

- (NSMutableArray *)parseDataToObjects:(id)dict {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        id profiles = [dict objectForKey:@"profiles"];
        if ([profiles isKindOfClass:[NSArray class]]) {
            for (id profile in profiles) {
                ProfileObject *profileObj = [[ProfileObject alloc] initWithDictionary:profile];
                [results addObject:profileObj];
            }
        }
    }
    
    return results;
}

@end
