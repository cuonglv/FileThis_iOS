//
//  FTMobileAppDelegate.m
//  FTMobile
//
//  Created by decuoi on 11/21/10.
//  Copyright Global Cybersoft 2010. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import <AdSupport/AdSupport.h>

#import "TestFlight.h"
#import "Crashlytics/Crashlytics.h"

#import "KKKeychain.h"
#import "KKPasscodeLock.h"

#import "AppleStoreObserver.h"
#import "FTMobileAppDelegate.h"
#import "LoginController.h"
#import "CommonVar.h"
#import "ConnectionViewController.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "FTSession.h"
#import "RotationAwareNavigationController.h"
#import "CustomPagerViewController.h"

@interface FTMobileAppDelegate ()

@property (strong) CustomPagerViewController *customPagerViewController;
@property (strong) UINavigationController *navigationController;
@property (strong) UIStoryboard *storyboard;
@end

@interface LoggingAssertionHandler : NSAssertionHandler
@end


CFAbsoluteTime gStartTime;
const NSUInteger MAX_INCORRECT_PASSCODE_ENTRIES = 3;


@implementation FTMobileAppDelegate

#pragma mark - Application lifecycle


/*
 
root view controller: either passcode or login
 
*/

/*
 
 Startup possibilities:
 1. autologin - launch to home screen
 2. passcode enabled - launch to passcode controller
 3. login - launch to login screen. This could happen
 on fresh install of app for existing users. They need to login
 one time so we can get golden ticket.
 
What is root view controller?

 Login Controller is root view controller... 
 

 */
-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard~iphone" bundle:nil];
    self.customPagerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OnboardPagerViewController"];;
    
    [CommonVar loadAtomicVar];
    NSString *oldTicket = [CommonVar ticket];
    BOOL usePasscode = oldTicket != nil;
    [[KKPasscodeLock sharedLock] setDefaultSettings];
    usePasscode = usePasscode && [[KKPasscodeLock sharedLock] isPasscodeRequired];

    [KKPasscodeLock sharedLock].eraseOption = NO;
    [KKPasscodeLock sharedLock].attemptsAllowed = MAX_INCORRECT_PASSCODE_ENTRIES;
    
    BOOL autoLogin = oldTicket != nil && !usePasscode;

    //self.navigationController = [[RotationAwareNavigationController alloc] initWithRootViewController:self.loginController];
    self.navigationController = [[RotationAwareNavigationController alloc] initWithRootViewController:self.customPagerViewController];
    self.navigationController.navigationBarHidden = YES;
    [self.window setRootViewController:self.navigationController];
    [self.window makeKeyAndVisible];
    
    if (usePasscode) {
        UIViewController *vc = [self passCodeController];
        [self.navigationController presentViewController:vc animated:NO completion:nil];
    } else if (autoLogin) {
        // validate that ticket ASAP 
        [FTSession sharedSession].loginDisabled = YES;
        [self loadConnections];
    }
    return YES;
}

//
//    is passcode configured?
//    
//    if pass code is configured
//        display pass code screen
//    
//    load defaults
//    if we have a user login ticket
//        load connections
//    
//    else....


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*
     1. start login if autologin enabled.
     2. launch
     */
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSString *oldTicket = [defaults stringForKey:@"ticket"];
//    if (oldTicket) {
//        [FTSession sharedSession].loginDisabled = YES;
//        [FTSession sharedSession].ticket = oldTicket;
//        [[FTSession sharedSession] ping:nil];
//    }
    
#ifdef DEBUG
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Launched in %f seconds", CFAbsoluteTimeGetCurrent() - gStartTime);
    });
#endif
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
    {
#ifdef DEBUG
        NSLog(@"startup deferred initalization");
#endif
        // Override point for customization after application launch.

        //NSLog(@"%@",[[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString]);
        //[TestFlight setDeviceIdentifier:[[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString]];

        // TODO: define app-id in target settings
        // NSString *filethisAppID = @"d04c60ee-751d-4bc6-9bb6-1bc658ecf312";
        // ref: https://testflightapp.com/dashboard/applications/591532/token/
        //NSString *fetchAppID = @"dd224878-f2e3-4cb9-9a4d-32ece11279d8";
        //[TestFlight takeOff:fetchAppID];
        [TestFlight takeOff:@"0c189e78-b474-4903-8c1a-7ce496638861"];
        [Crashlytics startWithAPIKey:@"0a3b082d429bf444002b71a9cb69b7b7019626be"];
        
        int oneMegabyte = 1024 * 1024;
        int diskCacheSizeInBytes = 100 * oneMegabyte;   // 100MB
        int memoryCacheSizeInBytes = 5 * oneMegabyte;   // 5MB
        
        NSURLCache *cache = [NSURLCache sharedURLCache];
#ifdef DEBUG
        NSLog(@"default url cache has %.1f disk cache, %.1f memory space", cache.diskCapacity / (1024.0*1024), cache.memoryCapacity / (1024.0*1024));
#endif
        [cache setDiskCapacity:diskCacheSizeInBytes];
        [cache setMemoryCapacity:memoryCacheSizeInBytes];
#ifdef DEBUG
        NSLog(@"adjusted url cache to %.1f disk cache, %.1f memory space", cache.diskCapacity / (1024.0*1024), cache.memoryCapacity / (1024.0*1024));
#endif
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:[AppleStoreObserver sharedObserver]];
        
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        
        [CommonVar loadVar];
        
        [self initEvernote];
        
#ifdef DEBUG
        NSLog(@"finished deferred after %f seconds", CFAbsoluteTimeGetCurrent() - gStartTime);
#endif
    });
    
    return YES;
}

- (void)notification:(NSNotification *)notification {
#ifdef DEBUG
    NSLog(@"NOTE: %@", notification);
#endif
}


//- (void)applicationDidBecomeActive:(UIApplication *)application
//{
//    if ([[KKPasscodeLock sharedLock] isPasscodeRequired]) {
//        UIViewController *vc = [self passCodeController];
////        KKPasscodeViewController *vc = [[KKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
////        vc.mode = KKPasscodeModeEnter;
////        vc.delegate = self;
//        
//        dispatch_async(dispatch_get_main_queue(),^ {
//            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//            
//            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//                nav.modalPresentationStyle = UIModalPresentationFormSheet;
//                nav.navigationBar.barStyle = UIBarStyleBlack;
//                nav.navigationBar.opaque = NO;
//            } else {
//                nav.navigationBar.tintColor = _navigationController.navigationBar.tintColor;
//                nav.navigationBar.translucent = _navigationController.navigationBar.translucent;
//                nav.navigationBar.opaque = _navigationController.navigationBar.opaque;
//                nav.navigationBar.barStyle = _navigationController.navigationBar.barStyle;
//            }
//            
//            [_navigationController presentModalViewController:nav animated:NO];
//        });
//        
//    }
//}


static void logURLCache() {
#ifdef DEBUG
    NSUInteger bytesUsedOnDisk = [[NSURLCache sharedURLCache] currentDiskUsage];
    NSUInteger bytesUsedInMemory = [[NSURLCache sharedURLCache] currentMemoryUsage];
    NSUInteger diskCapacity = [[NSURLCache sharedURLCache] diskCapacity];
    NSLog(@"URL cache contains %d bytes on disk, %d in memory, disk capacity is %d", bytesUsedOnDisk, bytesUsedInMemory,diskCapacity);
#endif
}

/*
 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
 */
- (void)applicationWillResignActive:(UIApplication *)application {
    CLS_LOG(@"applicationWillResignActive");
}


/*
 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
 If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
 */
- (void)applicationDidEnterBackground:(UIApplication *)application {
    CLS_LOG(@"applicationDidEnterBackground");
    logURLCache();
    // force quit app when going into background if passcode is enabled
    if ([[KKPasscodeLock sharedLock] isPasscodeRequired])
        exit(0); //must exit app when press iPhone Home button
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    CLS_LOG(@"applicationDidBecomeActive");
}


#pragma mark -
#pragma mark Memory management

/*
 Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later. 
 
 */
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    CLS_LOG(@"applicationDidReceiveMemoryWarning");
}


#pragma mark KKPasscodeViewControllerDelegate methods
- (void)didPasscodeEnteredCorrectly:(KKPasscodeViewController*)viewController {
    [self loadConnections];
}

- (void)didPasscodeEnteredIncorrectly:(KKPasscodeViewController*)viewController {
    //do nothing
    [self.navigationController dismissViewControllerAnimated:viewController completion:nil];
}

#pragma mark - MyFunc
-(UIImage *)defaultImage {
    return [UIImage imageNamed:@"Default"];
}

- (void)initEvernote {
//    NSString *EVERNOTE_HOST = BootstrapServerBaseURLStringSandbox;
//    NSString *CONSUMER_KEY = @"drewmwilson";
//    NSString *CONSUMER_SECRET = @"your-secret";
//    [EvernoteSession setSharedSessionHost:EVERNOTE_HOST
//          consumerKey:CONSUMER_KEY consumerSecret:CONSUMER_SECRET]; 
}

- (UIViewController *)passCodeController {
//        EnterPasscodeController *passcode = [[EnterPasscodeController alloc] initWithNibName:nil bundle:nil];
//        passcode.loginCon = login;

    KKPasscodeViewController *vc = [[KKPasscodeViewController alloc] initWithNibName:nil bundle:nil hideToolbar:YES];
    vc.mode = KKPasscodeModeEnter;
    vc.delegate = self;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//        vc.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default"]];
//        vc.backgroundView.backgroundColor = [UIColor clearColor];
//        // install background view
//        UIImageView *backgroundImageView = ;
//        backgroundImageView.frame = vc.view.frame;
//        vc.view.backgroundColor = [UIColor clearColor];
//        [vc.view addSubview:backgroundImageView];
//        [vc.view sendSubviewToBack:backgroundImageView];
    }
    vc.modalPresentationStyle = UIModalPresentationFormSheet;

//        dispatch_async(dispatch_get_main_queue(),^ { 
//            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    return vc;
}

- (void)resetConnectionViewController {
    [self.navigationController popToRootViewControllerAnimated:NO];
    ConnectionViewController *newConnectionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ConnectionViewController"];
    [self.navigationController pushViewController:newConnectionViewController animated:YES];
}

- (void)loadConnections {
    [[FTSession sharedSession] startup];
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.customPagerViewController performSegueWithIdentifier:@"GoHome" sender:self];
}

@end

// Stolen from http://nshipster.com/nsassertionhandler/
@implementation LoggingAssertionHandler

- (void)handleFailureInMethod:(SEL)selector
                       object:(id)object
                         file:(NSString *)fileName
                   lineNumber:(NSInteger)line
                  description:(NSString *)format, ...
{
    NSLog(@"NSAssert Failure: Method %@ for object %@ in %@#%i", NSStringFromSelector(selector), object, fileName, line);
}

- (void)handleFailureInFunction:(NSString *)functionName
                           file:(NSString *)fileName
                     lineNumber:(NSInteger)line
                    description:(NSString *)format, ...
{
    NSLog(@"NSCAssert Failure: Function (%@) in %@#%i", functionName, fileName, line);
}


@end
