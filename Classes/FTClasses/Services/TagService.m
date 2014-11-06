//
//  GetTagListService.m
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "TagService.h"
#import "CommonVar.h"
#import "NSString+Custom.h"

@implementation TagService

- (NSString *)serviceLink {
    if (self.action == kActionGetAllTags) {
        return [NSString stringWithFormat:kUrlGetAllTags, [CommonVar ticket]];
    } else if (self.action == kActionAddTag) {
        return [NSString stringWithFormat:kUrlAddTag, [self.tagName urlEncode], [CommonVar ticket]];
    } else if (self.action == kActionRemoveTag) {
        return [NSString stringWithFormat:kUrlRemoveTag, [self.tagId stringValue], [CommonVar ticket]];
    }
    
    return nil;
}

@end
