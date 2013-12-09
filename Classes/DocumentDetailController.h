//
//  DocumentDetailController.h
//  FTMobile
//
//  Created by decuoi on 12/20/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocumentController.h"
#import "DocumentMetadataView.h"
#import "DocumentPreviewView.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface DocumentDetailController : UIViewController <UITabBarDelegate, MFMailComposeViewControllerDelegate> {
    DocumentController *docCon;
    NSMutableDictionary *dictDoc;
    BOOL blnIsMetadataActive;

    IBOutlet UITabBar *myTabBar;
    IBOutlet UITabBarItem *tbiEmail, *tbiView, *tbiSettings, *tbiLogout;
    
    DocumentMetadataView *vwDocMetadata;
    DocumentPreviewView *vwDocPreview;
    
    UIImage *imgView, *imgInfo;
    
    BOOL blnCallFirstLoadLater;
    
    BOOL blnIsFirstLoad;
    IBOutlet UIView *vwMain;
}

@property (nonatomic, strong) DocumentController *docCon;
@property (nonatomic, strong) NSMutableDictionary *dictDoc;
@property (assign) BOOL blnIsMetadataActive;
@property (nonatomic, strong) UITabBarItem *tbiEmail;

#pragma mark -
#pragma mark UITabBarDelegate
- (void)handleViewBarBtn;
- (void)handleSettingsBarBtn;
- (void)handleLogoutBarBtn;

#pragma mark -
#pragma mark MyFunc
- (void)showMetadata;
- (void)showPreview;


#pragma mark -
#pragma mark Animation delegate
-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
@end
