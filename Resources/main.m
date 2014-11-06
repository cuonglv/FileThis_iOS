//
//  main.m
//  FTMobile
//
//  Created by decuoi on 11/21/10.
//  Copyright Global Cybersoft 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTMobileAppDelegate.h"

int main(int argc, char *argv[]) {
    gStartTime = CFAbsoluteTimeGetCurrent();
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([FTMobileAppDelegate class]));
    }
}
