//
//  UsageViewController.m
//  FileThis
//
//  Created by Cao Huu Loc on 5/30/14.
//
//

#import "UsageViewController.h"
#import "UserDataManager.h"
#import "FTSession.h"
#import "ConnectionUsageView.h"
#import "StorageUsageView.h"
#import "ReferralObject.h"
#import "ReferralsView.h"
#import "SubscriptionView.h"
#import "SubscriptionViewController.h"
#import "InviteFriendViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@interface UsageViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) ConnectionUsageView *connectionView;
@property (nonatomic, strong) StorageUsageView *storageView;
@property (nonatomic, strong) SubscriptionView *subscriptionView;
@property (nonatomic, strong) ReferralsView *referralsView;
@end

@implementation UsageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.titleLabel.text = NSLocalizedString(@"ID_USAGE_VIEW_TITLE", @"");
    self.loadingView = [[LoadingView alloc] init];
    
    //Init controls
    self.view.backgroundColor = [UIColor whiteColor];
    self.connectionView = [[ConnectionUsageView alloc] initWithFrame:CGRectMake(20, 100, 600, 100)];
    [self.scrollView addSubview:self.connectionView];
    
    self.storageView = [[StorageUsageView alloc] initWithFrame:CGRectMake(20, 100, 600, 100)];
    self.storageView.frame = [self.connectionView rectAtBottom:20 height:100];
    [self.scrollView addSubview:self.storageView];
    
    UINib *nib = [UINib nibWithNibName:@"SubscriptionView" bundle:[NSBundle mainBundle]];
    self.subscriptionView = [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    [self.scrollView addSubview:self.subscriptionView];
    
    self.referralsView = [[ReferralsView alloc] initWithFrame:CGRectMake(20, 100, 600, 100)];
    [self.scrollView addSubview:self.referralsView];
    
    //Add button events
    [self.subscriptionView.btnUpgrade addTarget:self action:@selector(clickedBtnUpgrade:) forControlEvents:UIControlEventTouchUpInside];
    [self.referralsView.btnInvite addTarget:self action:@selector(clickedBtnInvite:) forControlEvents:UIControlEventTouchUpInside];
    
    //Show connection usage, storage usage
    [self showAccountStorageInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //Get CRP information
    [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(getReferralInfo:threadObj:) argument:@""];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Layout
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    int left = 20;
    int top = 40;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        left = 10;
        top = 20;
    }
    self.connectionView.frame = CGRectMake(left, top + kIOS7ToolbarHeight, self.view.frame.size.width - left*2, 100);
    self.storageView.frame = [self.connectionView rectAtBottom:20 height:100];
    
    int height = 185;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        height = 150;
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        height = [self.subscriptionView.upgradeView bottom] + 15;
    }
    
    int y = [self.connectionView bottom] + 20;
    FTDestinationConnection *dest = [FTSession sharedSession].currentDestination;
    if (dest.name && ([dest.name isEqualToString:@"FileThis Cloud"])) {
        y = [self.storageView bottom] + 20;
        self.storageView.hidden = NO;
    } else {
        self.storageView.hidden = YES;
    }
    
    self.subscriptionView.interfaceOrientation = self.interfaceOrientation;
    self.subscriptionView.frame = CGRectMake(left, y, self.view.frame.size.width - left*2, height);
    
    [self.referralsView setLeft:[self.subscriptionView left]];
    [self.referralsView setTop:[self.subscriptionView bottom] + 20];
    [self.referralsView setWidth:self.subscriptionView.bounds.size.width];
    [self.referralsView setHeightToFitConstraint:0];
    int contentHeight = [self.referralsView bottom] + 20;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, contentHeight);
}

#pragma mark - Update GUI
- (void)showAccountStorageInfo {
    FTAccountSettings *settings = [FTSession sharedSession].settings;
    if (settings) {
        self.connectionView.maxQuota = settings.totalConnectionQuota;
        self.connectionView.progressValue = settings.totalConnectionUsage;
        self.storageView.maxQuota = settings.totalStorageQuota;
        self.storageView.progressValue = settings.totalStorageUsage;
        
        [self.subscriptionView refreshGUI];
    }
}

#pragma mark - Get CRP information
- (void)getReferralInfo:(id)dummy threadObj:(id<ThreadProtocol>)threadObj {
    if ([threadObj isCancelled]) {
        [threadObj releaseOperation];
        return;
    }
    
    // update session's settings
    [[FTSession sharedSession] getAccountPreferences:NULL];
    
    self.loadingView.threadObj = threadObj;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView startLoadingInView:self.view];
    });
    
    NSMutableArray *referrals = [[NSMutableArray alloc] initWithCapacity:0];
    NSDictionary *response = [[UserDataManager getInstance] getReferralInfo];
    if ([response isKindOfClass:[NSDictionary class]]) {
        NSArray *list = [response objectForKey:@"referrals"];
        if ([list isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in list) {
                ReferralObject *obj = [[ReferralObject alloc] initWithDictionary:dic];
                [referrals addObject:obj];
            }
        }
    }
    
    NSArray *arr = [[NSArray alloc] initWithArray:referrals];
    self.referralsView.arrReferrals = arr;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAccountStorageInfo];
        [self.referralsView refreshGUI];
        
        [self.view setNeedsLayout];
        [self.loadingView stopLoading];
    });
    
    if (![threadObj isCancelled]) {
    }
    
    [threadObj releaseOperation];
}

#pragma mark - Button events
- (void)clickedBtnUpgrade:(id)sender {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"button_upgrade_press" label:@"upgrade" value:nil] build]];
    
    SubscriptionViewController *target = [[SubscriptionViewController alloc] initWithNibName:@"SubscriptionViewController" bundle:[NSBundle mainBundle]];
    target.useBackButton = YES;
    [self.navigationController pushViewController:target animated:YES];
}

- (void)clickedBtnInvite:(id)sender {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"button_invite_press" label:@"invite a friend" value:nil] build]];
    
    InviteFriendViewController *target = [[InviteFriendViewController alloc] initWithNibName:@"InviteFriendViewController" bundle:[NSBundle mainBundle]];
    target.useBackButton = YES;
    [self.navigationController pushViewController:target animated:YES];
}

@end
