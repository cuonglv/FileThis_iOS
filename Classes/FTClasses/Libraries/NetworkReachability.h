//
//  IPhoneNetworkReachability.h
//  OnMat
//
//  Created by Manh Nguyen Ngoc on 4/7/13.
//
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface NetworkReachability : NSObject
{
    Reachability *internetReach;
    BOOL internetActive, firstTimeCallback;
}

+ (NetworkReachability *)getInstance;
- (BOOL)checkInternetActive;
- (BOOL)checkInternetActiveManually;
- (void)reloadCheckNetwork;

@end
