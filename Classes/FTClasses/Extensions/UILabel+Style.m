//
//  UILabel+Style.m
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//

#import "UILabel+Style.h"

@implementation UILabel (Style)

- (void)setFont:(UIFont *)font textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor text:(NSString *)text numberOfLines:(int)numberOfLines textAlignment:(NSTextAlignment)textAlignment {
    [self setFont:font];
    
    [self setTextColor:textColor];
    [self setText:text];
    [self setNumberOfLines:numberOfLines];
    [self setTextAlignment:textAlignment];
    
    if (backgroundColor == nil) {
        [self setBackgroundColor:[UIColor clearColor]];
    } else {
        [self setBackgroundColor:backgroundColor];
    }
}

@end
