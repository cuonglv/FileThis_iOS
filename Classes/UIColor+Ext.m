//
//  UIColor+Ext.m
//  FileThis
//
//  Created by Cuong Le on 1/8/14.
//
//

#import "UIColor+Ext.h"

@implementation UIColor (Ext)

+ (UIColor *)colorWithRedInt:(int)red greenInt:(int)green blueInt:(int)blue {
    return [UIColor colorWithRed:(float)red/255.0 green:(float)green/255.0 blue:(float)blue/255.0 alpha:1.0];
}

@end
