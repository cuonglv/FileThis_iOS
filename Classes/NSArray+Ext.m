//
//  NSArray+Ext.m
//  FileThis
//
//  Created by Cuong Le on 1/17/14.
//
//

#import "NSArray+Ext.h"

@implementation NSArray(Ext)

- (BOOL)isSameAsArray:(NSArray*)array {
    if ([array count] == 0 && [self count] == 0)
        return YES;
    
    for (id object in array) {
        if (![self containsObject:object])
            return NO;
    }
    
    for (id object in self) {
        if (![array containsObject:object])
            return NO;
    }
    
    return YES;
}

@end
