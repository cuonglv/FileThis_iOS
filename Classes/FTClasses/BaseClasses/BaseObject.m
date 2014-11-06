//
//  BaseObject.m
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//

#import "BaseObject.h"
#import "UILabel+Style.h"
#import "Constants.h"
#import <objc/runtime.h>

@implementation BaseObject

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        for (NSString *key in [dict allKeys]) {
            if ([self respondsToSelector:NSSelectorFromString(key)]) {
                [self setValue:[dict valueForKey:key] forKey:key];
            }
        }
    }
    return self;
}

- (NSArray *)allPropertyNames
{
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableArray *rv = [NSMutableArray array];
    
    unsigned i;
    for (i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [rv addObject:name];
    }
    
    free(properties);
    
    return rv;
}

+ (id)objectWithKey:(NSNumber *)key inArray:(NSArray*)array {
    NSArray *scanArray = [[NSArray alloc] initWithArray:array]; //Copy to avoid crash problem if array is changed
    
    for (BaseObject *obj in scanArray) {
        if ([obj.id isEqual:key])
            return obj;
    }
    return nil;
}

+ (NSMutableArray*)objectsWithKeys:(NSArray*)keys inArray:(NSArray*)array {
    NSArray *scanArray = [[NSArray alloc] initWithArray:array]; //Copy to avoid crash problem if array is changed
    
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (BaseObject *obj in scanArray) {
        if ([keys containsObject:obj.id])
            [ret addObject:obj];
    }
    return ret;
}

+ (NSMutableArray*)keysOfObjects:(NSArray*)objects {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (BaseObject *obj in objects) {
        [ret addObject:obj.id];
    }
    return ret;
}
@end
