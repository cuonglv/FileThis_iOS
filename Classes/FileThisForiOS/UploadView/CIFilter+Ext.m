//
//  CIFilter+Ext.m
//  MyImageFilter
//
//  Created by Cuong Le on 7/23/14.
//  Copyright (c) 2014 Cuong Le. All rights reserved.
//

#import "CIFilter+Ext.h"
#import <objc/runtime.h>

@implementation CIFilter(Ext)

- (NSArray *)imageInputAttributeKeys {
    // cache the enumerated image input attributes
    static const char *associationKey = "_storedImageInputAttributeKeys";
    NSArray *attributes = (NSArray *)objc_getAssociatedObject(self, associationKey);
    if (!attributes) {
        NSMutableArray *addingArray = [NSMutableArray array];
        for (NSString *key in self.inputKeys) {
            NSDictionary *attrDict = [self.attributes objectForKey:key];
            if ([[attrDict objectForKey:kCIAttributeType] isEqualToString:kCIAttributeTypeImage])
                [addingArray addObject:key];
        }
        
        attributes = [addingArray copy];
        objc_setAssociatedObject(self, associationKey, attributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return attributes;
}

@end
