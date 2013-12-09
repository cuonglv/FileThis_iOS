//
//  UIViewController_Ext.m
//  OnMat
//
//  Created by Cuong Le Viet on 1/5/13.
//
//

#import "UIViewController_Ext.h"

@implementation UIViewController (Ext)

- (BOOL)isInLandscapeMode {
    return (self.view.frame.size.width > self.view.frame.size.height);
}

@end
