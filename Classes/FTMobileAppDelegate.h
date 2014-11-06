//
//  FTMobileAppDelegate.h
//  FTMobile
//
//  Created by decuoi on 11/21/10.
//  Copyright Global Cybersoft 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPasscodeViewController.h"
#import "SWRevealViewController.h"
#import "MenuViewController.h"
#import "OverviewViewController.h"
#import "DocumentObject.h"
#import "DocumentCabinetObject.h"

//#define DEBUG_SET_USER_ACTION_REQUIRED_FOR_1ST_CREDENTIALS_QUESTION   YES
#define DEBUG_TEST_NULL_CURRENT_DESTINATION_AFTER_REACTIVATING_APP YES
//#define ENABLE_NSLOG_REQUEST   YES
//release: must remove all #define above


@interface FTMobileAppDelegate : NSObject <UIApplicationDelegate, KKPasscodeViewControllerDelegate, SWRevealViewControllerDelegate, MenuDelegate, MenuViewControllerDelegate> {
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, readonly) UIImage *defaultImage;
@property (strong) UINavigationController *navigationController;
@property (nonatomic, assign) BOOL allowShowPickerPopover;

- (void)startLoadingData;
- (void)selectMenu:(MenuItem)menuItem animated:(BOOL)animated;
- (void)goToCustomPagerViewController;

- (void)goToDocumentDetail:(DocumentObject *)documentObj documents:(NSMutableArray *)documents;
- (void)goToDocumentDetail:(DocumentObject *)documentObj documents:(NSMutableArray *)documents actionType:(ACTIONTYPE)action;
- (void)goToDocumentDetail:(DocumentObject *)documentObj documents:(NSMutableArray *)documents actionType:(ACTIONTYPE)action parameter:(id)param;

- (void)goToDocumentGroupViewController:(id)documentGroup;
- (void)gotoPurchase;
- (void)goToUssageView;
- (void)goToInviteFriend;

- (void)popCurrentViewController;
- (void)jumpToDocumentGroupListViewController;
- (void)clearData;
- (void)reloadData;

@property (assign) BOOL showingPasscodeFromBackground;

@end

extern CFAbsoluteTime gStartTime;

