//
//  MenuViewController.m
//  FileThis
//
//  Created by Cuong Le on 12/10/13.
//
//

#import "MenuViewController.h"
#import "Constants.h"
#import "MyDetailViewController.h"
#import "FTSession.h"
#import "CommonFunc.h"
#import "UIView+ExtLayout.h"
#import "MyDebugLogViewController.h"
#import "FTMobileAppDelegate.h"
#import "InviteFriendView.h"

#define kMenuRowHeight  45.0
#define kMenuRowHeight_iphone4  35.0
#define NUM_ROW_NOT_DISPLAYED   2

@interface MenuViewController ()
@property (strong) BorderView *topBarView;
@property (nonatomic, strong) UIButton *menuButton;
@property (strong) UITableView *myTable;
@property (atomic, assign) MenuItem selectedMenuItem;
@property (assign) int selectedRowIndex;
@property (nonatomic, strong) NSString *fullName;
@property (assign) BOOL usingFTCloudDestination;
@property (nonatomic, strong) InviteFriendView *inviteView;
@property (nonatomic, strong) MyProgressView *usageProgressView;
@property (nonatomic, strong) UIView *rightBorderView;
@property (nonatomic, strong) UIButton *logButton;
@end

#pragma mark -

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.view.backgroundColor = [UIColor whiteColor];
        
        self.usingFTCloudDestination = NO;
        self.selectedRowIndex = -1;
        [self initMenuItems];
        
        self.topBarView = [[BorderView alloc] initWithFrame:CGRectMake(0, 0, kMenuWidth-1, 66.0) borderColor:kBorderLightGrayColor borderWidths:OffsetMake(0, 0, 0, 1) superView:self.view];
        self.topBarView.backgroundColor = kTextOrangeColor;
        
        float iconHeight = self.topBarView.frame.size.height - kIOS7CarrierbarHeight - 4;
        
        self.menuButton = [CommonLayout createImageButton:CGRectMake(0, kIOS7CarrierbarHeight + 2, iconHeight * 0.8, iconHeight) image:[UIImage imageNamed:@"FTiOS_logo.png"] contentMode:UIViewContentModeScaleAspectFit touchTarget:self touchSelector:@selector(menuButtonTouched) superView:self.topBarView];
        
        self.myTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 66.0, kMenuWidth-1, [self heightForMenuRow] * (self.dictMenuItems.count-NUM_ROW_NOT_DISPLAYED))];
        self.myTable.backgroundColor = [UIColor clearColor];
        self.myTable.rowHeight = [self heightForMenuRow];
        self.myTable.separatorColor = kBorderLightGrayColor;
        self.myTable.delegate = self;
        self.myTable.dataSource = self;
        self.myTable.scrollEnabled = self.myTable.allowsSelectionDuringEditing = NO;
        [self.view addSubview:self.myTable];
        
        self.premiumBoxView = [[PremiumBoxView alloc] initWithFrame:[self.myTable rectAtBottom:20 height:200]];
        [self.premiumBoxView setLeft:10];
        [self.premiumBoxView setWidth:self.myTable.frame.size.width - 18];
        [self.premiumBoxView resize]; //Loc Cao (rezise and rearrange components for iPhone GUI)
        [self.view addSubview:self.premiumBoxView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedSettings:) name:FTGetAccountInfo object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(destinationConfigured:) name:FTCurrentDestinationUpdated object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(destinationConfigured:) name:FTFixCurrentDestination object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(destinationConfigured:) name:FTMissingCurrentDestination object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(destinationConfigured:) name:FTListDestinations object:nil];
        
        UIFont *font;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            font = [CommonLayout getFont:FontSizeXXSmall isBold:NO isItalic:YES];
        } else {
            font = [CommonLayout getFont:FontSizeXSmall isBold:NO isItalic:YES];
        }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            CGRect rect = [self.premiumBoxView rectAtBottom:10 height:110];
            InviteFriendView *inviteView = [[InviteFriendView alloc] initWithFrame:rect];
            self.inviteView = inviteView;
            self.inviteView.hidden = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
            [self.inviteView.btnInvite addTarget:self action:@selector(handleInviteButton) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:inviteView];
        }
        
        int y = self.view.frame.size.height - 80;
        int height = self.view.frame.size.height - y;
        self.usageProgressView = [[MyProgressView alloc] initWithFrame:CGRectMake(20, y, kMenuWidth-40, height) font:font textColor:kTextGrayColor tintColor:kTextOrangeColor trackTintColor:kBackgroundLightGrayColor progressBarWidth:kMenuWidth-40 addDetailLabel:YES superView:self.view];
        self.usageProgressView.delegate = self;
        self.usageProgressView.hidden = NO;
        
        self.rightBorderView = [CommonLayout drawLine:CGRectMake(kMenuWidth-1, 0, 1, self.view.frame.size.height) color:kBorderLightGrayColor superView:self.view];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.inviteView.hidden = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
    [self destinationConfigured:nil];
    [self.view bringSubviewToFront:self.rightBorderView];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    self.inviteView.hidden = UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)initMenuItems {
    self.dictMenuItems = [[NSMutableDictionary alloc] init];
    NSString *username = [CommonFunc getUsername];
    if (username == nil)
        username = @"";
    
    [self.dictMenuItems setObject:username forKey:[NSNumber numberWithInt:MenuItemSettings]];
    [self.dictMenuItems setObject:NSLocalizedString(@"ID_DOCUMENTS", @"") forKey:[NSNumber numberWithInt:MenuItemDocuments]];
    [self.dictMenuItems setObject:NSLocalizedString(@"ID_DESTINATION", @"") forKey:[NSNumber numberWithInt:MenuItemDestination]];
    [self.dictMenuItems setObject:NSLocalizedString(@"ID_CONNECTIONS", @"") forKey:[NSNumber numberWithInt:MenuItemConnections]];
    [self.dictMenuItems setObject:NSLocalizedString(@"ID_RECENTLY_ADDED", @"") forKey:[NSNumber numberWithInt:MenuItemRecent]];
    [self.dictMenuItems setObject:NSLocalizedString(@"ID_UPLOAD", @"") forKey:[NSNumber numberWithInt:MenuItemUpload]];
    [self.dictMenuItems setObject:NSLocalizedString(@"ID_LOGOUT", @"") forKey:[NSNumber numberWithInt:MenuItemLogout]];
    
    self.dictMenuIcons = [[NSMutableDictionary alloc] init];
    [self.dictMenuIcons setObject:@"user_icon_orange.png" forKey:[NSNumber numberWithInt:MenuItemSettings]];
    [self.dictMenuIcons setObject:@"document_icon_orange.png" forKey:[NSNumber numberWithInt:MenuItemDocuments]];
    [self.dictMenuIcons setObject:@"destination_icon_orange.png" forKey:[NSNumber numberWithInt:MenuItemDestination]];
    [self.dictMenuIcons setObject:@"connection_icon_orange.png" forKey:[NSNumber numberWithInt:MenuItemConnections]];
    [self.dictMenuIcons setObject:@"clock_icon_orange.png" forKey:[NSNumber numberWithInt:MenuItemRecent]];
    [self.dictMenuIcons setObject:@"upload_icon_orange.png" forKey:[NSNumber numberWithInt:MenuItemUpload]];
    [self.dictMenuIcons setObject:@"out_icon_orange.png" forKey:[NSNumber numberWithInt:MenuItemLogout]];
}

#pragma mark - Layout
- (void)viewWillLayoutSubviews {
    [self relayout];
}

- (void)relayout {
    [super relayout];
    float bottomProgessView = self.view.frame.size.height-20;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        bottomProgessView += 15;
    }
    
    CGRect rect = [self.premiumBoxView rectAtBottom:10 height:110];
    self.inviteView.frame = rect;
    
    [self.usageProgressView setBottom:bottomProgessView];
    [self.logButton moveToTopOfView:self.usageProgressView offset:10];
    [self.rightBorderView setHeight:self.view.frame.size.height];
    [self.view bringSubviewToFront:self.rightBorderView];
}

- (BOOL)shouldRelayoutBeforeRotation {
    return NO;
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dictMenuItems count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int menuItem = indexPath.row;
    if (menuItem == MenuItemRecent || menuItem == MenuItemUpload) {
        if ([[FTSession sharedSession] isUsingFTDestination])
            return [self heightForMenuRow];
        return 0.0;
    } else if (menuItem == MenuItemDocuments) {
        if ([FTSession sharedSession].currentDestination == nil) {
            return 0.0;
        }
    }
    
    return [self heightForMenuRow];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"menuCell";
    
    MenuCell *cell = (MenuCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MenuCell alloc] initWithReuseIdentifier:cellIdentifier tableView:tableView];
    }
    NSString *text, *leftImageName;
    UIImage *rightImage = nil;
    
    if (indexPath.row == 0) {
        rightImage = [UIImage imageNamed:@"setting_icon_orange.png"];
    }
    
    text = [self.dictMenuItems objectForKey:[NSNumber numberWithInt:indexPath.row]];
    leftImageName = [self.dictMenuIcons objectForKey:[NSNumber numberWithInt:indexPath.row]];
    
    UIFont *font;
    UIColor *textColor;
    if (indexPath.row == 0) {
        font = [CommonLayout getFont:FontSizeMedium isBold:NO isItalic:YES];
        textColor = kTextOrangeColor;
    } else {
        font = [CommonLayout getFont:FontSizeMedium isBold:NO isItalic:NO];
        textColor = kTextGrayColor;
    }
    [cell setLeftImage:[UIImage imageNamed:leftImageName] rightImage:rightImage text:text font:font unselectedTextColor:textColor selected:(indexPath.row==self.selectedRowIndex)];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedMenuItem = indexPath.row;
    self.selectedRowIndex = indexPath.row;
    [self.myTable reloadData];
    
    [self performSelector:@selector(menuViewControllerItemSelected:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.2]; //to see selection effect
}

#pragma mark - Button
- (void)menuButtonTouched {
    [self.menuViewControllerDelegate menu_ShouldClose:self];
}

- (void)handleLogButton {
    MyDebugLogViewController *vc = [[MyDebugLogViewController alloc] initWithNibName:nil bundle:nil];
    [((FTMobileAppDelegate*)[UIApplication sharedApplication].delegate).navigationController presentViewController:vc animated:YES completion:^{  }];
}

- (void)handleInviteButton {
    FTMobileAppDelegate *app = (FTMobileAppDelegate*)[UIApplication sharedApplication].delegate;
    [app goToInviteFriend];
}

#pragma mark - MyFunc
- (float)heightForMenuRow {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (![CommonFunc isTallScreen])
            return kMenuRowHeight_iphone4;
    }
    return kMenuRowHeight;
}

- (void)selectMenu:(MenuItem)menuItem animated:(BOOL)animated {
    if (self.selectedMenuItem != menuItem) {
        self.selectedMenuItem = menuItem;
        self.selectedRowIndex = menuItem;
        //[self.myTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedMenuItem inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self.myTable reloadData];
    }
    [self performSelector:@selector(menuViewControllerItemSelected:) withObject:[NSNumber numberWithBool:animated] afterDelay:0.0]; //no need to see selection effect
}

- (void)menuViewControllerItemSelected:(NSNumber*)animatedNumber {
    [self.menuViewControllerDelegate menuViewControllerItemSelected:self.selectedMenuItem animated:[animatedNumber boolValue]];
}

- (void)refreshUsageView {
    FTAccountSettings *settings = [FTSession sharedSession].settings;
    if (!settings)
        return;
    
    double docBytes = [settings storage];
    double storageQuota = [settings storageQuota];
    double percentage;
    if (docBytes >= storageQuota)
        percentage = 1;
    else
        percentage = (float)docBytes / (float)storageQuota;
    
    NSString *docBytesString;
    /*if (docBytes < 1000) {
        docBytesString = [NSString stringWithFormat:@"%.0f KB", docBytes];
    } else {
        docBytes /= 1000;
        if (docBytes < 1000) {
            docBytesString = [NSString stringWithFormat:@"%.1f MB", docBytes];
        } else {
            docBytesString = [NSString stringWithFormat:@"%.1f GB", docBytes/1000];
        }
    }*/
    docBytesString = [CommonLayout storageTextFromKB:docBytes decimalPlaces:1];
    
    BOOL isFTDestination = NO;
    FTDestinationConnection *dest = [FTSession sharedSession].currentDestination;
    if (dest.name && ([dest.name isEqualToString:@"FileThis Cloud"])) {
        isFTDestination = YES;
    }
    
    NSString *progressText = @"";
    if (isFTDestination) {
        NSString *storageQuotaString;
        /*if (storageQuota < 1000) {
            storageQuotaString = [NSString stringWithFormat:@"%.0f KB", docBytes];
        } else {
            storageQuota /= 1000;
            if (storageQuota < 1000) {
                storageQuotaString = [NSString stringWithFormat:@"%.0f MB", storageQuota];
            } else {
                storageQuotaString = [NSString stringWithFormat:@"%.0f GB", storageQuota/1000];
            }
        }*/
        
        storageQuotaString = [CommonLayout storageTextFromKB:storageQuota decimalPlaces:2];
        progressText = [NSString stringWithFormat:@"Using %@ (%.0f%%) of %@", docBytesString, percentage*100, storageQuotaString];
    } else {
        percentage = 0;
        int count =[[FTSession sharedSession] countConnections];
        if (settings.totalConnectionQuota > 0) {
            percentage = (float)count / settings.totalConnectionQuota;
        }
        progressText = [NSString stringWithFormat:@"Using %d (%.0f%%) of %d connections", count, percentage*100, settings.totalConnectionQuota];
    }
    
    [self.usageProgressView setProgressValue:percentage text:progressText];
}

#pragma mark - MyProgressViewDelegate
- (void)progressViewClickedDetailButton {
    self.selectedRowIndex = -1;
}

#pragma mark - Nofification events
- (void)updatedSettings:(NSNotification *)notification {
    FTAccountSettings *settings = [FTSession sharedSession].settings;
    if (settings) {
        self.fullName = [NSString stringWithFormat:@"%@ %@",settings.firstName,settings.lastName];
        [self.dictMenuItems setObject:self.fullName forKey:[NSNumber numberWithInt:0]];
        [self.myTable reloadData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshUsageView];
        });
    }
}

- (void)destinationConfigured:(id)object {
    int row = [self.myTable numberOfRowsInSection:0];
    if (![[FTSession sharedSession] isUsingFTDestination])
    {
        row -= NUM_ROW_NOT_DISPLAYED;
    }
    float height = [self heightForMenuRow] * row;
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.myTable setHeight:height];
        [self.myTable reloadData];
        [self.premiumBoxView setTop:[self.myTable bottom] + 20];
        
        [self refreshUsageView];
    });
}

@end
