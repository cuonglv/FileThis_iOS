//
//  SelectCabinetsView.m
//  FileThis
//
//  Created by Cuong Le on 1/23/14.
//
//

#import "SelectCabinetsView.h"
#import "CabinetDataManager.h"

@implementation SelectCabinetsView


#pragma mark - Override
- (NSMutableArray*)getAllItems {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    NSArray *arr = [[NSArray alloc] initWithArray:[[CabinetDataManager getInstance] getAllCabinets]];
    for (CabinetObject *cabObj in arr) {
        if ([cabObj.id intValue] > 0) {
            [ret addObject:cabObj];
        }
    }
    return ret;
}

- (TagCollectionCellBackgroundType)backgroundTypeForSelectedItem {
    return TagCollectionCellBackgroundTypeRectOrangeWithTail;
}

- (TagCollectionCellBackgroundType)backgroundTypeForSelectedItemToRemove {
    return TagCollectionCellBackgroundTypeRectOrangeX;
}

- (TagCollectionCellBackgroundType)backgroundTypeForUnselectedItem {
    return TagCollectionCellBackgroundTypeRectWhiteWithTail;
}

- (TagCollectionCellBackgroundType)backgroundTypeForUnselectedItemToRemove {
    return TagCollectionCellBackgroundTypeRectWhiteX;
}

- (NSString*)titleForSelectedItems {
    return @"Selected Cabinets:";
}
- (NSString*)titleForSelectedItem {
    return @"Selected Cabinet:";
}
- (NSString*)titleForUnselectedItems {
    return @"Touch to select Cabinet:";
}

- (BOOL)removeDataForItem:(id)item {
    return [[CabinetDataManager getInstance] removeCabinet:item];
}

- (NSString*)nameOfItem:(id)item {
    return ((CabinetObject*)item).name;
}

- (NSString*)rightTextOfItem:(id)item {
    return [[(CabinetObject*)item docCount] stringValue];
}

- (NSString*)confirmMessageForRemoval:(id)item {
    return [NSString stringWithFormat:NSLocalizedString(@"ID_CONFIRM_REMOVE_CABINET_S", @""),((CabinetObject*)item).name];
}

@end
