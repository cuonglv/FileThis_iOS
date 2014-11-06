//
//  NameBaseObject.m
//  FileThis
//
//  Created by Cuong Le on 3/3/14.
//
//

#import "NameBaseObject.h"

@implementation NameBaseObject

- (int)insertIntoArraySortedByName:(NSMutableArray*)array {
    int index = 0;
    for (int count = [array count]; index < count; index++) {
        NameBaseObject *obj = [array objectAtIndex:index];
        if ([self.name compare:obj.name options:NSCaseInsensitiveSearch] == NSOrderedDescending)
            break;
    }
    [array insertObject:self atIndex:index];
    return index;
}

@end
