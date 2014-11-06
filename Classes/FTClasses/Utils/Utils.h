//
//  Utils.h
//  ezInventory
//
//  Created by Manh Nguyen Ngoc on 9/21/13.
//  Copyright (c) 2013 Enlitech LLC. All rights reserved.
//

#import "BaseObject.h"

@interface Utils : BaseObject

+ (void)showAlertMessageWithTitle:(NSString *)title tag:(int)tag content:(NSString *)content delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles;
+ (BOOL)isValidEmail:(NSString *)emailString;

@end
