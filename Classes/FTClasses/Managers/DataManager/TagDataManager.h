//
//  TagDataManager.h
//  FileThis
//
//  Created by Manh nguyen on 12/16/13.
//
//

#import "BaseDataManager.h"
#import "TagObject.h"

@interface TagDataManager : BaseDataManager

+ (TagDataManager *)getInstance;
- (NSArray *)getAllTags;
- (NSArray *)getNonEmptyTags;
- (BOOL)checkTagNameExisted:(NSString *)tagName;
- (TagObject *)addTag:(NSString *)tagName;
- (BOOL)removeTag:(TagObject*)tagObject;
@end
