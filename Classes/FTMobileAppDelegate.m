//
//  FTMobileAppDelegate.m
//  FTMobile
//
//  Created by decuoi on 11/21/10.
//  Copyright Global Cybersoft 2010. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import <AdSupport/AdSupport.h>

#import "Crashlytics/Crashlytics.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

#import "KKKeychain.h"
#import "KKPasscodeLock.h"
#import "MyLog.h"

#import "AppleStoreObserver.h"
#import "FTMobileAppDelegate.h"
#import "CommonVar.h"
#import "CommonFunc.h"
#import "ConnectionViewController.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "FTSession.h"
#import "RotationAwareNavigationController.h"
#import "CustomPagerViewController.h"
#import "DestinationViewController.h"
#import "DocumentGroupListViewController.h"
#import "UploadDocumentViewController.h"
#import "DocumentSearchViewController.h"
#import "TagDataManager.h"
#import "CabinetDataManager.h"
#import "CommonDataManager.h"
#import "LoginViewController.h"
#import "OnboardingViewController.h"
#import "ThreadManager.h"
#import "DocumentDetailViewController.h"
#import "DocumentDataManager.h"
#import "CacheManager.h"
#import "DocumentCabinetObject.h"
#import "DocumentGroupViewController.h"
#import "ProfileDataManager.h"
#import "RecentDocumentsController.h"
#import "Reachability.h"
#import "DestinationWelcomeViewController.h"
#import "Utils.h"
#import "NetworkReachability.h"
#import "TagDataManager.h"
#import "CabinetDataManager.h"
#import "DocumentsBlankViewController.h"
#import "BlankViewController.h"
#import "SubscriptionViewController.h"
#import "Appirater.h"
#import "ProfileService.h"
#import "UsageViewController.h"
#import "InviteFriendViewController.h"

@interface FTMobileAppDelegate () 
@property (strong) CustomPagerViewController *customPagerViewController;
@property (strong) UIStoryboard *storyboard;
@property (strong) SWRevealViewController *slidingViewController;
@property (assign) BOOL loggedIn;
@property (nonatomic, strong) BlankViewController *blankViewController;
@property (strong) UIButton *btnRightSideArea;

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
    //Loc test
    //[FTSession setHostName:@"filethis.com"];
    //[[CacheManager getInstance] setServerUrl:[NSString stringWithFormat:@"https://%@/ftapi/ftapi?", @"filethis.com"]];
    //---
    
    [[DocumentDataManager getInstance] restoreCachedData];
    
    self.storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard~iphone" bundle:nil];
    self.showingPasscodeFromBackground = NO;
    self.loggedIn = NO;
    self.allowShowPickerPopover = YES;
    
    [CommonVar setStoryboard:self.storyboard];
    self.customPagerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OnboardPagerViewController"];
    
    [CommonVar loadAtomicVar];
    NSString *oldTicket = [CommonVar ticket];
    BOOL usePasscode = oldTicket != nil;
    [[KKPasscodeLock sharedLock] setDefaultSettings];
    usePasscode = usePasscode && [[KKPasscodeLock sharedLock] isPasscodeRequired];

    [KKPasscodeLock sharedLock].eraseOption = NO;
    [KKPasscodeLock sharedLock].attemptsAllowed = MAX_INCORRECT_PASSCODE_ENTRIES;
    
    BOOL autoLogin = oldTicket != nil && !usePasscode;

    //self.navigationController = [[RotationAwareNavigationController alloc] initWithRootViewController:[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]]];
    
    //+++Loc Cao
    LoginViewController *login = [[[CommonFunc idiomClassWithName:@"LoginViewController"] alloc] initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]];
    self.navigationController = [[RotationAwareNavigationController alloc] initWithRootViewController:login];
    //---
    
    [CommonVar setMainNavigationController:self.navigationController];
    
    self.navigationController.navigationBarHidden = YES;
    [self.window setRootViewController:self.navigationController];
    [self.window makeKeyAndVisible];
    
    if ([[CommonFunc getUsername] length] == 0)
        return YES;
    
    if (usePasscode) {
        UIViewController *vc = [self passCodeController];
        [self.navigationController presentViewController:vc animated:NO completion:nil];
    } else if (autoLogin) {
        // validate that ticket ASAP
        [FTSession sharedSession].loginDisabled = YES;
        [self startLoadingData];
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
    
    //////////////////////////////////////////////////
    //Init Google Analytics session
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-13181691-7"];

    
#ifdef ENABLE_NSLOG_REQUEST
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Launched in %f seconds", CFAbsoluteTimeGetCurrent() - gStartTime);
    });
#endif
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
    {
#ifdef ENABLE_NSLOG_REQUEST
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
        //0c189e78-b474-4903-8c1a-7ce496638861
        [Crashlytics startWithAPIKey:@"0a3b082d429bf444002b71a9cb69b7b7019626be"];
        
        int oneMegabyte = 1024 * 1024;
        int diskCacheSizeInBytes = 100 * oneMegabyte;   // 100MB
        int memoryCacheSizeInBytes = 5 * oneMegabyte;   // 5MB
        
        NSURLCache *cache = [NSURLCache sharedURLCache];
#ifdef ENABLE_NSLOG_REQUEST
        NSLog(@"default url cache has %.1f disk cache, %.1f memory space", cache.diskCapacity / (1024.0*1024), cache.memoryCapacity / (1024.0*1024));
#endif
        [cache setDiskCapacity:diskCacheSizeInBytes];
        [cache setMemoryCapacity:memoryCacheSizeInBytes];
#ifdef ENABLE_NSLOG_REQUEST
        NSLog(@"adjusted url cache to %.1f disk cache, %.1f memory space", cache.diskCapacity / (1024.0*1024), cache.memoryCapacity / (1024.0*1024));
#endif
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:[AppleStoreObserver sharedObserver]];
        
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        
        [CommonVar loadVar];

        [self initEvernote];
        
#ifdef ENABLE_NSLOG_REQUEST
        NSLog(@"finished deferred after %f seconds", CFAbsoluteTimeGetCurrent() - gStartTime);
#endif
    });
    
    //+++Loc Cao
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    [userDefault setValue:nil forKey:kSelectedSectionCabinetList];
    [userDefault setValue:nil forKey:kSelectedSectionCabinetThumb];
    [userDefault setValue:nil forKey:kSelectedSectionProfileList];
    [userDefault setValue:nil forKey:kSelectedSectionProfileThumb];
    //---

    return YES;
}

- (void)notification:(NSNotification *)notification {
#ifdef ENABLE_NSLOG_REQUEST
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
#ifdef ENABLE_NSLOG_REQUEST
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
    [MyLog writeLogWithText:kMyLogText_AppWillResignActive];
    
    //Cuong: debug crash
//#ifdef DEBUG_TEST_NULL_CURRENT_DESTINATION_AFTER_REACTIVATING_APP
//    [FTSession sharedSession].app_is_reactivating = YES;
//#endif
}


/*
 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
 If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
 */

- (void)applicationDidEnterBackground:(UIApplication *)application {
    CLS_LOG(@"applicationDidEnterBackground");
    logURLCache();
    // force quit app when going into background if passcode is enabled
//    if ([[KKPasscodeLock sharedLock] isPasscodeRequired])
//        exit(0); //must exit app when press iPhone Home button
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (self.loggedIn) {
        if ([[KKPasscodeLock sharedLock] isPasscodeRequired]) {
            self.allowShowPickerPopover = NO;
            UIViewController *vc = [self passCodeController];
            [self.navigationController presentViewController:vc animated:NO completion:nil];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [Appirater appLaunched];
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
    if (!self.showingPasscodeFromBackground) {
        [self startLoadingData];
        self.showingPasscodeFromBackground = YES;
    }
}

- (void)didPasscodeEnteredIncorrectly:(KKPasscodeViewController*)viewController {
    //do nothing
    //[self.navigationController dismissViewControllerAnimated:viewController completion:nil];
}

#pragma mark - MyDetailViewControllerDelegate
- (void)menuButtonTouched:(id)sender {
//    if (self.slidingViewController.isOpen == NO) {
//        [self.slidingViewController openSlider:YES completion:nil];
//    } else {
//        [self.slidingViewController closeSlider:YES completion:nil];
//    }
    [self.slidingViewController revealToggleAnimated:YES];
}

- (void)menu_ShouldOpen:(id)sender {
    [CommonVar setIsShowingMenu:YES];
    if ([self.slidingViewController.frontViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navCon = (UINavigationController*)self.slidingViewController.frontViewController;
        if ([navCon.visibleViewController isKindOfClass:[MyDetailViewController class]]) {
            MyDetailViewController *myDetailViewController = (MyDetailViewController*)navCon.visibleViewController;
            myDetailViewController.menuButton.hidden = YES;
            [myDetailViewController relayout];
            myDetailViewController.view.userInteractionEnabled = NO;
        }
    }
    [self.slidingViewController setFrontViewPosition:FrontViewPositionRight animated:YES];
}

- (void)menu_ShouldClose:(id)sender {
    [self.slidingViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
    [CommonVar setIsShowingMenu:NO];
}
/*- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    UINavigationController *navCon = (UINavigationController*)self.slidingViewController.frontViewController;
    MyDetailViewController *vc = [navCon.viewControllers firstObject];
    if ([vc respondsToSelector:@selector(relayout)])
    {
        [vc relayout];
    }
    NSLog(@"revealController didMoveToPosition");
}*/
#pragma mark - SWRevealViewControllerDelegate
- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position {
    if (position == FrontViewPositionLeft) {
        if ([self.slidingViewController.frontViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navCon = (UINavigationController*)self.slidingViewController.frontViewController;
            if ([navCon.visibleViewController isKindOfClass:[MyDetailViewController class]]) {
                MyDetailViewController *myDetailViewController = (MyDetailViewController*)navCon.visibleViewController;
                myDetailViewController.menuButton.hidden = NO;
                [myDetailViewController relayout];
                myDetailViewController.view.userInteractionEnabled = YES;
            }
        }
    }
    
    if (position == FrontViewPositionRight) {
        self.btnRightSideArea.hidden = NO;
    } else {
        self.btnRightSideArea.hidden = YES;
    }
}

#pragma mark - MenuViewControllerDelegate
- (void)menuViewControllerItemSelected:(MenuItem)menuItem animated:(BOOL)animated {
    if (menuItem == MenuItemLogout) {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"menu_logout_press" label:@"log out" value:nil] build]];
        
        // Do logout
        [self clearData];
        
        [[FTSession sharedSession] logout];
        [self.navigationController popToRootViewControllerAnimated:YES];
        self.loggedIn = NO;
        return;
    }
    
    NSString *gaiTrackAction = @"";
    NSString *gaiTrackLabel = @"";
    
    MyDetailViewController *vc = nil;
    switch (menuItem) {
        case MenuItemSettings:
            gaiTrackAction = @"menu_settings_press";
            gaiTrackLabel = @"settings";
            
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"NewSettings"];
            break;
        case MenuItemConnections:
            gaiTrackAction = @"menu_connections_press";
            gaiTrackLabel = @"connections";
            
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConnectionViewController"];
            break;
        case MenuItemDestination:
            gaiTrackAction = @"menu_destination_press";
            gaiTrackLabel = @"destination";
            
            if ([FTSession sharedSession].currentDestination)
                vc = [[DestinationViewController alloc] initWithNibName:nil bundle:nil];
            else
                vc = [[DestinationWelcomeViewController alloc] initWithNibName:nil bundle:nil];
            break;
        case MenuItemDocuments:
            gaiTrackAction = @"menu_documents_press";
            gaiTrackLabel = @"documents";
            
            if ([[FTSession sharedSession] isUsingFTDestination]) {
                vc = [[[CommonFunc idiomClassWithName:@"DocumentGroupListViewController"] alloc] initWithNibName:@"DocumentGroupListViewController" bundle:[NSBundle mainBundle]];
            } else {
                vc = [[DocumentsBlankViewController alloc] initWithNibName:@"DocumentsBlankViewController" bundle:[NSBundle mainBundle]];
                
                FTDestination *destination = [FTDestination destinationWithId:[FTSession sharedSession].currentDestination.destinationId];
                ((DocumentsBlankViewController *)vc).destination = destination;
            }
            
            break;
        case MenuItemUpload:
            gaiTrackAction = @"menu_upload_press";
            gaiTrackLabel = @"upload";
            
            vc = [[UploadDocumentViewController alloc] initWithNibName:nil bundle:nil];
            break;
        case MenuItemRecent:
            gaiTrackAction = @"menu_recent_press";
            gaiTrackLabel = @"recently added";
            
            vc = [[RecentDocumentsController alloc] initWithNibName:@"DocumentListViewController" bundle:[NSBundle mainBundle]];
            break;
        default:
            break;
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:gaiTrackAction label:gaiTrackLabel value:nil] build]];
    
    if (!vc)
        return;
    
    vc.myDetailViewControllerDelegate = self;
    UINavigationController *navCon = (UINavigationController*)self.slidingViewController.frontViewController;
    [navCon popToRootViewControllerAnimated:NO];
    if (self.slidingViewController.frontViewPosition == FrontViewPositionRight) {
        [navCon setViewControllers:@[vc] animated:NO];
        [self.slidingViewController revealToggleAnimated:animated];
    } else {
        [navCon setViewControllers:@[vc] animated:animated];
//        [navCon pushViewController:vc animated:YES];
    }
}

- (void)clearData {
    [CommonVar setSortDocumentBy:DateAdded_NewestFirst]; //Restore default sort type
    
    [[CabinetDataManager getInstance] clearAll];
    [[CommonDataManager getInstance] clearAll];
    [[TagDataManager getInstance] clearAll];
    [[DocumentDataManager getInstance] clearAll];
    [[ProfileDataManager getInstance] clearAll];
}

#pragma mark - Button events
- (void)clickedBtnRightSideArea:(id)sender {
    [self.slidingViewController revealToggleAnimated:YES];
}

#pragma mark - Notification

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
    KKPasscodeViewController *vc = [[KKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
    vc.hideNavigationBar = YES;
    vc.mode = KKPasscodeModeEnter;
    vc.delegate = self;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    return vc;
}

- (void)reloadData {
    if (![[NetworkReachability getInstance] checkInternetActive]) {
        NSLog(@"%@", self.navigationController.topViewController);

        BOOL popToRoot = NO;
        
        if ([self.navigationController.topViewController isKindOfClass:[SWRevealViewController class]]) {
            SWRevealViewController *sw = (SWRevealViewController *)self.navigationController.topViewController;
            if ([sw.frontViewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navViewController = (UINavigationController *)sw.frontViewController;
                UIViewController *frontController = [navViewController topViewController];
                if ([frontController isKindOfClass:[BlankViewController class]]) {
                    if ([[TagDataManager getInstance] countObjects] == 0) {
                        popToRoot = YES;
                    }
                    
                    if ([[CabinetDataManager getInstance] countObjects] == 0) {
                        popToRoot = YES;
                    }
                    
                    if ([[DocumentDataManager getInstance] countObjects] == 0) {
                        popToRoot = YES;
                    }
                    
                    if ([[ProfileDataManager getInstance] countObjects] == 0) {
                        popToRoot = YES;
                    }
                }
            }
        }
        
        if (popToRoot) {
            [self.blankViewController.loadingView stopLoading];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (void)startLoadingData {
    [Crashlytics setUserName:[CommonFunc getUsername]];
    
    if (![[NetworkReachability getInstance] checkInternetActiveManually]) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:NSLocalizedString(@"ID_NO_INTERNET_CONNECTION", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self.blankViewController = [[BlankViewController alloc] initWithNibName:nil bundle:nil];
        self.blankViewController.view.backgroundColor = [UIColor whiteColor];
        self.blankViewController.loadingView = [[LoadingView alloc] init];
        [self.blankViewController.loadingView startLoadingInView:self.blankViewController.view];
    });
    
    // Load common data
    self.blankViewController.loadingView.threadObj = [[CommonDataManager getInstance] loadCommonData];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        MenuViewController *backVC = [[MenuViewController alloc] initWithNibName:nil bundle:nil];
        backVC.menuViewControllerDelegate = self;
        
        UINavigationController *frontVC = [[UINavigationController alloc] initWithRootViewController:self.blankViewController];
        self.slidingViewController = [[SWRevealViewController alloc] initWithRearViewController:backVC frontViewController:frontVC];
        self.slidingViewController.rearViewRevealWidth = kMenuWidth;
        self.slidingViewController.frontViewShadowOffset = CGSizeZero;
        self.slidingViewController.delegate = self;
        [self.slidingViewController.navigationController setNavigationBarHidden:YES animated:NO];

        [self.navigationController pushViewController:self.slidingViewController animated:NO];
        
        self.btnRightSideArea = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnRightSideArea.frame = CGRectMake(kMenuWidth, 0, 1500, 1500);
        self.btnRightSideArea.backgroundColor = [UIColor clearColor];
        [self.btnRightSideArea addTarget:self action:@selector(clickedBtnRightSideArea:) forControlEvents:UIControlEventTouchUpInside];
        [self.slidingViewController.view addSubview:self.btnRightSideArea];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(destinationConfigured:) name:FTCurrentDestinationUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(destinationConfigured:) name:FTFixCurrentDestination object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(destinationConfigured:) name:FTMissingCurrentDestination object:nil];
    
    [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(executeLoadDestination:threadObj:) argument:@""];
    //wating for notification, then call destinationConfigured:
}

- (void)destinationConfigured:(id)object {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self finishLoadingData];
    });
}

- (void)finishLoadingData {
    self.loggedIn = YES;
    [[FTSession sharedSession] startup];
    
    MenuItem menuItem;
    if ([[FTSession sharedSession] isUsingFTDestination]) {     //using FileThis Cloud destination, go to Documents screen
        menuItem = MenuItemDocuments;
    } else {
        FTDestinationConnection *currentDest = [FTSession sharedSession].currentDestination;
        if (currentDest && !currentDest.needsAuthentication && !currentDest.needsRepair) { //using valid destination (which is not FileThis Cloud), go to Connection screen
            menuItem = MenuItemConnections;
        } else {  //invalid destination, go to Destination screen
            menuItem = MenuItemDestination;
        }
    }
    [self selectMenu:menuItem animated:NO];
    self.blankViewController = nil;
}

- (void)goToCustomPagerViewController {
    self.customPagerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OnboardPagerViewController"];
    [self.navigationController pushViewController:self.customPagerViewController animated:YES];
}

- (void)goToDocumentDetail:(DocumentObject *)documentObj documents:(NSMutableArray *)documents {
    [self goToDocumentDetail:documentObj documents:documents actionType:ACTIONTYPE_UNKNOWN parameter:nil];
}

- (void)goToDocumentDetail:(DocumentObject *)documentObj documents:(NSMutableArray *)documents actionType:(ACTIONTYPE)action
{
    [self goToDocumentDetail:documentObj documents:documents actionType:action parameter:nil];
}

- (void)goToDocumentDetail:(DocumentObject *)documentObj documents:(NSMutableArray *)documents actionType:(ACTIONTYPE)action parameter:(id)param {
    if ([[documentObj.kind lowercaseString] isEqualToString:[kPDF lowercaseString]]) {
        DocumentDetailViewController *vc = nil;
        vc = [[[CommonFunc idiomClassWithName:@"DocumentDetailViewController"] alloc] initWithNibName:@"DocumentDetailViewController" bundle:[NSBundle mainBundle]];
        vc.actionType = action;
        vc.documentObj = documentObj;
        vc.arrDocumentsInGroup = documents;
        if ([param isKindOfClass:[DocumentSearchCriteria class]]) {
            vc.documentSearchCriteria = param;
        }
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_INFO", @"") tag:0 content:NSLocalizedString(@"ID_PDF_TYPE_WARNING", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
    }
}

- (void)selectMenu:(MenuItem)menuItem animated:(BOOL)animated {
    [(MenuViewController*)self.slidingViewController.rearViewController selectMenu:menuItem animated:animated];
}

- (void)goToDocumentGroupViewController:(id)documentGroup {
    DocumentGroupViewController *vc = nil;
    vc = [[DocumentGroupViewController alloc] initWithNibName:@"DocumentListViewController" bundle:[NSBundle mainBundle]];
    
    vc.documentGroup = documentGroup;
    if ([documentGroup isKindOfClass:[DocumentCabinetObject class]]) {
        vc.documentObjects = ((DocumentCabinetObject *)documentGroup).arrDocuments;
    } else {
        vc.documentObjects = ((DocumentProfileObject *)documentGroup).arrDocuments;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoPurchase {
    SubscriptionViewController *target = [[SubscriptionViewController alloc] initWithNibName:@"SubscriptionViewController" bundle:[NSBundle mainBundle]];
    target.myDetailViewControllerDelegate = self;
    UINavigationController *navCon = (UINavigationController*)self.slidingViewController.frontViewController;
    [navCon popToRootViewControllerAnimated:NO];
    if (self.slidingViewController.frontViewPosition == FrontViewPositionRight) {
        [navCon setViewControllers:@[target] animated:NO];
        [self.slidingViewController revealToggleAnimated:YES];
    } else {
        [navCon setViewControllers:@[target] animated:YES];
    }
}

- (void)goToUssageView {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"button_usage_press" label:@"usage" value:nil] build]];
    
    UsageViewController *target = [[UsageViewController alloc] initWithNibName:@"UsageViewController" bundle:[NSBundle mainBundle]];
    target.myDetailViewControllerDelegate = self;
    UINavigationController *navCon = (UINavigationController*)self.slidingViewController.frontViewController;
    [navCon popToRootViewControllerAnimated:NO];
    if (self.slidingViewController.frontViewPosition == FrontViewPositionRight) {
        [navCon setViewControllers:@[target] animated:NO];
        [self.slidingViewController revealToggleAnimated:YES];
    } else {
        [navCon setViewControllers:@[target] animated:YES];
    }
}

- (void)goToInviteFriend {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"button_invite_press" label:@"invite a friend" value:nil] build]];
    
    InviteFriendViewController *target = [[InviteFriendViewController alloc] initWithNibName:@"InviteFriendViewController" bundle:[NSBundle mainBundle]];
    target.myDetailViewControllerDelegate = self;
    UINavigationController *navCon = (UINavigationController*)self.slidingViewController.frontViewController;
    [navCon popToRootViewControllerAnimated:NO];
    if (self.slidingViewController.frontViewPosition == FrontViewPositionRight) {
        [navCon setViewControllers:@[target] animated:NO];
        [self.slidingViewController revealToggleAnimated:YES];
    } else {
        [navCon setViewControllers:@[target] animated:YES];
    }
}

- (void)popCurrentViewController {
}

- (void)executePreloadData:(id)dummy threadObj:(id<ThreadProtocol>)threadObj {
    if (![threadObj isCancelled]) {
        [[CabinetDataManager getInstance] getAllCabinets];
        [[ProfileDataManager getInstance] getAllProfiles];
        [[TagDataManager getInstance] getAllTags];
    }
    [threadObj releaseOperation];
}

- (void)executeLoadDestination:(id)dummy threadObj:(id<ThreadProtocol>)threadObj {
    if (![threadObj isCancelled]) {
        [[FTSession sharedSession] loadDestinations];
    }
    [threadObj releaseOperation];
}

- (void)jumpToDocumentGroupListViewController {
    for (UIViewController *vc in [self.navigationController viewControllers]) {
        if ([vc isKindOfClass:[SWRevealViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

@end

#pragma mark -

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
//

@end
