//
//  SelectTagsView.m
//  FileThis
//
//  Created by Cuong Le on 12/25/13.
//
//

#import "SelectTagsView.h"
#import "TagDataManager.h"

@interface SelectTagsView() <UIAlertViewDelegate>

@end

@implementation SelectTagsView

#pragma mark - Override
- (NSMutableArray*)getAllItems {
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[[TagDataManager getInstance] getAllTags]]; //Copy to avoid crash problem if array is changed
    return arr;
}

- (TagCollectionCellBackgroundType)backgroundTypeForSelectedItem {
    return TagCollectionCellBackgroundTypeTagOrangeWithTail;
}

- (TagCollectionCellBackgroundType)backgroundTypeForSelectedItemToRemove {
    return TagCollectionCellBackgroundTypeTagOrangeX;
}

- (TagCollectionCellBackgroundType)backgroundTypeForUnselectedItem {
    return TagCollectionCellBackgroundTypeTagWhiteWithTail;
}

- (TagCollectionCellBackgroundType)backgroundTypeForUnselectedItemToRemove {
    return TagCollectionCellBackgroundTypeTagWhiteX;
}

- (NSString*)titleForSelectedItems {
    return @"Selected tags:";
}
- (NSString*)titleForSelectedItem {
    return @"Selected tag:";
}
- (NSString*)titleForUnselectedItems {
    return @"Touch to select tag:";
}

- (BOOL)removeDataForItem:(id)item {
    return [[TagDataManager getInstance] removeTag:item];
}

- (NSString*)nameOfItem:(id)item {
    return ((TagObject*)item).name;
}

- (NSString*)rightTextOfItem:(id)item {
    return [[(TagObject*)item docCount] stringValue];
}

- (NSString*)confirmMessageForRemoval:(id)item {
    return [NSString stringWithFormat:NSLocalizedString(@"ID_CONFIRM_REMOVE_TAG_S", @""),((TagObject*)item).name];
}
@end
