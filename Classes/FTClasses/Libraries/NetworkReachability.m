//
//  IPhoneNetworkReachability.m
//  OnMat
//
//  Created by Manh Nguyen Ngoc on 4/7/13.
//
//

#import "NetworkReachability.h"
#import "FTMobileAppDelegate.h"

@implementation NetworkReachability
static BOOL hasChecked = NO;
static NetworkReachability *instance = nil;

+ (NetworkReachability *)getInstance {
    @synchronized(self) {
        if (instance == nil)
            instance = [[NetworkReachability alloc] init];
    }
    
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        firstTimeCallback = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
        
        internetReach = [Reachability reachabilityForInternetConnection];
        [internetReach startNotifier];
        
        // Wait for notification
    }
    
    return self;
}

- (void)checkNetworkStatus:(NSNotification *)notification {
    // Using flag to avoid call observe many times.
    if (hasChecked == YES) return;
    
    Reachability *curReach = [notification object];
    if (curReach != nil && curReach == internetReach) {
        NetworkStatus networkStatus = [internetReach currentReachabilityStatus];
        if (networkStatus == NotReachable) {
            internetActive = NO;
        } else if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN) {
            internetActive = YES;
        }
        
        FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate reloadData];
        hasChecked = YES;
        
        // Then, reload check network flag
        [NSThread detachNewThreadSelector:@selector(reloadCheckNetwork) toTarget:self withObject:nil];
    }
}

- (void)reloadCheckNetwork {
    [NSThread sleepForTimeInterval:5];
    hasChecked = NO;
}

- (BOOL)checkInternetActive {
    return internetActive;
}

- (BOOL)checkInternetActiveManually {
    NetworkStatus networkStatus = [internetReach currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        internetActive = NO;
    } else if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN) {
        internetActive = YES;
    }
    
    return internetActive;
}

@end
