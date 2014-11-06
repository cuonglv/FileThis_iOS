//
//  KeyValueItem.m
//  TKD
//
//  Created by decuoi on 5/10/11.
//  Copyright 2011 Global Cybersoft. All rights reserved.
//

#import "KeyValueItem.h"


@implementation KeyValueItem
@synthesize key, value, description, data, deleted;

- (id)init {
    if (self = [super init]) {
        self.key = self.value = self.description = nil;
        data = nil;
        deleted = NO;
    }
    return self;
}

- (id)initWithKey:(NSString*)k value:(NSString*)v {
    if (self = [super init]) {
        self.key = k;
        self.value = v;
        self.description = nil;
        deleted = NO;
    }
    return self;
}

- (BOOL)isValueBefore:(KeyValueItem*)keyValueItem {
    return [value compare:keyValueItem.value] == NSOrderedAscending;
}

- (BOOL)isKeyBefore:(KeyValueItem*)keyValueItem {
    //return [key compare:keyValueItem.key] == NSOrderedAscending;
    return ([key longLongValue] < [keyValueItem.key longLongValue]);
}

- (int)insertIntoArraySortedByValue:(NSMutableArray*)keyValueItemArray ascending:(BOOL)ascending {
    int count = [keyValueItemArray count];
    
    if (ascending) {
        for (int i = 0; i < count; i++) {
            KeyValueItem *currentItem = [keyValueItemArray objectAtIndex:i];
            if ([self isValueBefore:currentItem]) { //if found suitable position -> insert this item into array
                [keyValueItemArray insertObject:self atIndex:i];
                return i;
            }
            
        }
    } else {
        for (int i = 0; i < count; i++) {
            KeyValueItem *currentItem = [keyValueItemArray objectAtIndex:i];
            if ([currentItem isValueBefore:self]) { //if found suitable position -> insert this item into array
                [keyValueItemArray insertObject:self atIndex:i];
                return i;
            }
        }
    }
    //if not found suitable position -> add this item to the end of array
    [keyValueItemArray addObject:self];
    return count;
}

- (int)insertIntoArraySortedByKey:(NSMutableArray*)keyValueItemArray ascending:(BOOL)ascending {
    int count = [keyValueItemArray count];
    
    if (ascending) {
        for (int i = 0; i < count; i++) {
            KeyValueItem *currentItem = [keyValueItemArray objectAtIndex:i];
            if ([self isKeyBefore:currentItem]) { //if found suitable position -> insert this item into array
                [keyValueItemArray insertObject:self atIndex:i];
                return i;
            }
            
        }
    } else {
        for (int i = 0; i < count; i++) {
            KeyValueItem *currentItem = [keyValueItemArray objectAtIndex:i];
            if ([currentItem isKeyBefore:self]) { //if found suitable position -> insert this item into array
                [keyValueItemArray insertObject:self atIndex:i];
                return i;
            }
        }
    }
    //if not found suitable position -> add this item to the end of array
    [keyValueItemArray addObject:self];
    return count;
}

+ (KeyValueItem*)itemWithKey:(NSString*)k inArray:(NSArray*)keyValueItemArray {
    for (int i = 0, count = [keyValueItemArray count]; i < count; i++) {
        KeyValueItem *item = [keyValueItemArray objectAtIndex:i];
        if ([item.key isEqualToString:k]) {
            return item;
        }
    }
    return nil;
}

+ (KeyValueItem*)itemWithValue:(NSString*)v inArray:(NSArray*)keyValueItemArray {
    for (int i = 0, count = [keyValueItemArray count]; i < count; i++) {
        KeyValueItem *item = [keyValueItemArray objectAtIndex:i];
        if ([item.value isEqualToString:v]) {
            return item;
        }
    }
    return nil;
}

+ (NSMutableArray*)itemsWithKeys:(NSArray*)keys inArray:(NSArray*)keyValueItemArray {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (int i = 0, count = [keyValueItemArray count]; i < count; i++) {
        KeyValueItem *item = [keyValueItemArray objectAtIndex:i];
        if ([keys containsObject:item.key])
            [ret addObject:item];
    }
    return ret;
}

+ (NSMutableArray*)itemsWithoutKeys:(NSMutableArray*)keys inArray:(NSArray*)keyValueItemArray {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (int i = 0, count = [keyValueItemArray count]; i < count; i++) {
        KeyValueItem *item = [keyValueItemArray objectAtIndex:i];
        if (![keys containsObject:item.key])
            [ret addObject:item];
    }
    return ret;
}

+ (int)indexOfItemWithKey:(NSString*)k inArray:(NSArray*)keyValueItemArray {
    for (int i = 0, count = [keyValueItemArray count]; i < count; i++) {
        KeyValueItem *item = [keyValueItemArray objectAtIndex:i];
        if ([item.key isEqualToString:k]) {
            return i;
        }
    }
    return -1;
}

+ (NSMutableArray*)getKeysOfItems:(NSArray*)items {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (KeyValueItem *item in items) {
        [ret addObject:item.key];
    }
    return ret;
}

+ (NSMutableArray*)getValuesOfItems:(NSArray*)items {
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[items count]];
    for (int i=0, count=[items count]; i < count; i++) {
        KeyValueItem *item = [items objectAtIndex:i];
        [result addObject:item.value];
    }
    return result;
}

+ (NSString*)getValueByKey:(NSString*)k ofItems:(NSArray*)items {    
    for (KeyValueItem* item in items) {
        if ([item.key isEqualToString:k]) {
            return item.value;
        }
    }
    return nil;
}

+ (NSString*)getValuesStringByKeys:(NSArray*)keys ofItems:(NSArray*)items {    
    if ([keys count] == 0)
        return @"";
    
    NSString *result = [KeyValueItem getValueByKey:[keys objectAtIndex:0] ofItems:items];
    for (int i=1, count=[keys count]; i < count; i++) {
        NSString *val = [KeyValueItem getValueByKey:[keys objectAtIndex:i] ofItems:items];
        if (val) {
            result = [result stringByAppendingFormat:@", %@", val];
        }
    }
    return result;
}

+ (NSString*)getValuesStringOfItems:(NSArray*)items {    
    if ([items count] == 0)
        return @"";
    
    NSString *result = ((KeyValueItem*)[items objectAtIndex:0]).value;
    for (int i=1, count=[items count]; i < count; i++) {
        result = [result stringByAppendingFormat:@", %@", ((KeyValueItem*)[items objectAtIndex:i]).value];
    }
    return result;
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
+ (float)maxTextWidthForItems:(NSArray*)items font:(UIFont*)font {
    float maxWidth = 10;
    for (KeyValueItem *item in items) {
        float width = [item.value sizeWithFont:font].width;
        if (maxWidth < width)
            maxWidth = width;
    }
    return maxWidth + 2;
}
#pragma GCC diagnostic pop

@end
