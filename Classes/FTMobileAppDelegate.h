//
//  FTMobileAppDelegate.h
//  FTMobile
//
//  Created by decuoi on 11/21/10.
//  Copyright Global Cybersoft 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPasscodeViewController.h"

@interface FTMobileAppDelegate : NSObject <UIApplicationDelegate, KKPasscodeViewControllerDelegate> {
}

@property (nonatomic, strong) IBOutlet UIWindow *window;

@property (nonatomic, readonly) UIImage *defaultImage;

- (void)resetConnectionViewController;
- (void)loadConnections;

@end

extern CFAbsoluteTime gStartTime;

