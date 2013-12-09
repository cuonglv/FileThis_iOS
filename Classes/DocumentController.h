//
//  DocumentController.h
//  FTMobile
//
//  Created by decuoi on 11/21/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "MyAnimatedView.h"
#import "MyControlView.h"
#import "SortCriteriaView.h"


@interface DocumentController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITabBarDelegate, SortCriteriaDelegate> {
    IBOutlet UIView *vwSearchTags, *vwSearchText;
    UITableView *myTableView;
    IBOutlet UIImageView *imvCabinet;
    IBOutlet UILabel *lblCabinet;
    IBOutlet UILabel *lblSearchTagTitle, *lblSearchTextTitle;
    UIButton *btnSelectCabinet, *btnSelectTag;
    IBOutlet UITextField *tfSearchTag, *tfSearchText;
    UILabel *lblTagText, *lblTagClear;  //just use these labels to locating touch event

    NSArray *arrDoc;
    NSMutableArray *arrDocThumb;
    
    int iCabId;
    NSString *sTagIds, *sSearchText, *sSortBy;
    BOOL blnSortDescending;
    
    int iDocPageSize;
    MyAnimatedView *vwAnimated;
    
    IBOutlet UITabBar *myTabBar;
    IBOutlet UITabBarItem *tbiSort, *tbiUpload, *tbiSettings, *tbiLogout;
    IBOutlet UIView *vwPaging;
    
    SortCriteriaView *vwSort;
@private
    BOOL blnExitThread;
    
    BOOL blnNeedToReloadDocInfo;
    BOOL blnNeedToScrollToTop;
    
    BOOL blnIsShowingSortControl;
    
    BOOL blnAllCabsLoaded;
    BOOL blnAllTagsLoaded;
    
    
    //Paging
    IBOutlet UIButton *btnPageMore;
    IBOutlet UILabel *lblPageInfo;
    int iCurrentDocCount;
    
    UIColor *colorMyDarkBlue;
    
    long long lGetThumbThreadCount;
    
    
}
@property (nonatomic, strong) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) NSArray *arrDoc;
@property (nonatomic, strong) IBOutlet UILabel *lblCabinet;
@property (nonatomic, strong) UILabel *lblSearchTagTitle, *lblSearchTextTitle;
@property (nonatomic, strong) IBOutlet UIButton *btnSelectCabinet, *btnSelectTag;

@property (nonatomic, strong) UITextField *tfSearchTag, *tfSearchText;


@property (assign) int iCabId;
@property (nonatomic, strong) NSString *sTagIds;
@property (nonatomic, strong) NSString *sSortBy;
@property (assign) BOOL blnSortDescending;
@property (assign) int iDocPageSize;

@property (assign) BOOL blnNeedToReloadDocInfo;

- (void)loadData;
- (void)setCabId:(int)cabId name:(NSString *)cabName type:(NSString *)cabType;
- (void)getServerThumbnails;

#pragma mark -
#pragma mark Button
- (void)handleSortBarBtn;
- (void)handleSettingsBarBtn;
- (void)handleLogoutBarBtn;

- (IBAction)handleSelectCabinet;
- (IBAction)handleSelectTag;

- (void)handleUploadBarBtn;

#pragma mark -
#pragma mark MyFunc
//- (void)viewDocumentMetadata:(int)rowIndex;

#pragma mark Sort Criteria
- (void)didCancelSortingCriteria;
- (void)didSelectSortingCriteria;
- (void)enableSortControl:(BOOL)showSortControl;

- (void)loadAllCabs;
- (void)loadAllTags;
- (void)loadAccountInfo;

#pragma mark -
#pragma mark Paging
- (IBAction)handleBtnPageMore;

#pragma mark -
#pragma mark Logout
- (void)logout;
- (void)logoutInBackground:(NSString*)ticket;
@end
