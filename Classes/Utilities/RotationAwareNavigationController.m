//
//  RotationAwareNavigationController.m
//  FileThis
//
//  Created by Drew Wilson on 4/22/13.
//
//

#import "RotationAwareNavigationController.h"

@implementation RotationAwareNavigationController

- (UIViewController *)frontMost {
    UIViewController *frontMost = self.topViewController;
    if (frontMost.presentedViewController != nil && ![frontMost.presentedViewController isKindOfClass:[UINavigationController class]])
        frontMost = frontMost.presentedViewController;
    return frontMost;
}

- (BOOL)shouldAutorotate {
    UIViewController *frontMost = [self frontMost];
    if (frontMost != nil)
        return [frontMost shouldAutorotate];
    else
        return [super shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations {
    UIViewController *frontMost = [self frontMost];
    if (frontMost != nil)
        return [frontMost supportedInterfaceOrientations];
    else
        return [super supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *frontMost = [self frontMost];
    if (frontMost != nil)
        return [frontMost preferredInterfaceOrientationForPresentation];
    else
        return [super preferredInterfaceOrientationForPresentation];
}

@end
