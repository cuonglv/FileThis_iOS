//
//  UILabel+Style.h
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (UILabel_Style)

- (void)setFont:(UIFont *)font textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor text:(NSString *)text numberOfLines:(int)numberOfLines textAlignment:(NSTextAlignment)textAlignment;

@end
