//
//  RotationAwareNavigationController.m
//  FileThis
//
//  Created by Drew Wilson on 4/22/13.
//
//

#import "RotationAwareNavigationController.h"
#import "CommonVar.h"

@implementation RotationAwareNavigationController

- (UIViewController *)frontMost {
    UIViewController *frontMost = self.topViewController;
    if (frontMost.presentedViewController != nil && ![frontMost.presentedViewController isKindOfClass:[UINavigationController class]])
        frontMost = frontMost.presentedViewController;
    return frontMost;
}

- (BOOL)shouldAutorotate {
    if ([CommonVar lockedOrientation])
        return NO;
    
    UIViewController *frontMost = [self frontMost];
    if (frontMost != nil)
        return [frontMost shouldAutorotate];
    
    return [super shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return UIInterfaceOrientationMaskPortrait;
    
    if ([CommonVar lockedOrientation])
        return UIInterfaceOrientationMaskPortrait;
    
    UIViewController *frontMost = [self frontMost];
    if (frontMost != nil)
        return [frontMost supportedInterfaceOrientations];
    else
        return [super supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return UIInterfaceOrientationPortrait;
    
    if ([CommonVar lockedOrientation])
        return UIInterfaceOrientationPortrait;
    
    UIViewController *frontMost = [self frontMost];
    if (frontMost != nil)
        return [frontMost preferredInterfaceOrientationForPresentation];
    else
        return [super preferredInterfaceOrientationForPresentation];
}

@end
