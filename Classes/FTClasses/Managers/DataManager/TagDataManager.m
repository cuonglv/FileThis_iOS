//
//  TagDataManager.m
//  FileThis
//
//  Created by Manh nguyen on 12/16/13.
//
//

#import "TagDataManager.h"
#import "TagService.h"
#import "TagObject.h"
#import "EventManager.h"
#import "CommonLayout.h"
#import "Utils.h"

@interface BaseDataManager ()
@property (nonatomic, strong) NSMutableArray *allObjects;
@property (nonatomic, strong) NSMutableDictionary *findObjectByIdDictionary;
@end

@implementation TagDataManager
static TagDataManager *instance = nil;

+ (TagDataManager *)getInstance {
    @synchronized(self) {
        if (instance == nil) {
            instance = [[TagDataManager alloc] init];
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

- (NSArray *)getAllTags {
    if (self.allObjects != nil) {
        return [self getAllObjects];
    }
    
    [self reloadAll];
    return [self getAllObjects];
}

- (void)reloadAll {
    @synchronized(self) {
        TagService *service = [[TagService alloc] initWithAction:kActionGetAllTags];
        NSError *error;
        id dataResponse = [service sendRequestToServer:&error];
        if (dataResponse) {
            self.allObjects = [self parseDataToObjects:dataResponse];
            [self updateFindObjectByIdDictionary];
        } else {
            /*dispatch_async(dispatch_get_main_queue(), ^{
             [CommonLayout showWarningAlert:NSLocalizedString(@"ID_WARNING_CANNOT_LOAD_TAG_LIST", @"") errorMessage:[error localizedDescription] delegate:nil];
             });*/
        }
    }
}

- (NSArray *)getNonEmptyTags {
    NSArray *allTags = [self getAllTags];
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (TagObject *tagObj in allTags) {
        if ([tagObj.docCount intValue] > 0)
            [ret addObject:tagObj];
    }
    return [NSArray arrayWithArray:ret];
}


- (NSMutableArray *)parseDataToObjects:(id)dict {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        id account = [dict objectForKey:@"account"];
        if ([account isKindOfClass:[NSDictionary class]]) {
            id tags = [account objectForKey:@"tags"];
            if (tags != nil && [tags isKindOfClass:[NSArray class]]) {
                for (id tag in tags) {
                    TagObject *tagObj = [[TagObject alloc] initWithDictionary:tag];
                    [results addObject:tagObj];
                }
            }
        }
    }
    
    return results;
}

- (BOOL)checkTagNameExisted:(NSString *)tagName {
    for (TagObject *tagObj in [self getAllObjects]) {
        if ([[tagObj.name lowercaseString] isEqualToString:[tagName lowercaseString]]) {
            return YES;
        }
    }
    return NO;
}

- (TagObject *)addTag:(NSString *)tagName {
    @synchronized(self) {
        TagService *service = [[TagService alloc] initWithAction:kActionAddTag];
        service.tagName = tagName;
        NSError *error = nil;
        id dataResponse = [service sendRequestToServer:&error];
        
        if (dataResponse) {
            TagObject *tagObj = [[TagObject alloc] init];
            tagObj.name = tagName;
            tagObj.id = [NSNumber numberWithInt:[dataResponse intValue]];
            tagObj.docCount = [NSNumber numberWithInt:0];
            return tagObj;
        } else if (error) {
            if ([service.errorMessage length] > 0 && [service.errorMessage rangeOfString:@"Exception"].location != NSNotFound) {
                [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:service.errorMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
            } else {
                [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:NSLocalizedString(@"ID_CANNOT_ADD_TAG", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
            }
        }
        
        return nil;
    }
}

- (BOOL)removeTag:(TagObject*)tagObject {
    @synchronized(self) {
        TagService *service = [[TagService alloc] initWithAction:kActionRemoveTag];
        service.tagId = tagObject.id;
        NSError *error = nil;
        [service sendRequestToServer:&error];
        if (service.responseStatusCode == 200) {
            // Post event to UI
            Event *event = [[Event alloc] initEventWithType:EVENT_TYPE_REMOVE_TAG];
            [event setContent:tagObject];
            [[EventManager getInstance] callbackToChannelProtocolWithEvent:event channel:CHANNEL_DATA];
            
            [self.allObjects removeObject:tagObject];
            return YES;
        } else if (error) {
            if ([service.errorMessage length] > 0 && [service.errorMessage rangeOfString:@"Exception"].location != NSNotFound) {
                [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:service.errorMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
            } else {
                [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:NSLocalizedString(@"ID_CANNOT_REMOVE_TAG", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
            }
        }
        return NO;
    }
}

@end
