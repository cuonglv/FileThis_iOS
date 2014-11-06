//
//  GetTagListService.h
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "BaseService.h"

#define kUrlGetAllTags  @"compact=true&json=true&op=taglist&ticket=%@"
#define kUrlAddTag      @"compact=true&json=true&op=addtag&name=%@&ticket=%@"
#define kUrlRemoveTag   @"op=removetag&json=true&ids=%@&ticket=%@"

// Tag Actions
#define kActionGetAllTags   0
#define kActionAddTag       1
#define kActionRemoveTag    2

@interface TagService : BaseService

@property (nonatomic, copy) NSString *tagName;
@property (nonatomic, copy) NSNumber *tagId;

@end
