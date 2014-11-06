//
//  BaseViewController.m
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//

#import "BaseViewController.h"
#import "Constants.h"
#import "EventManager.h"
#import "CommonVar.h"
#import "CommonLayout.h"
#import <Crashlytics/Crashlytics.h>

@interface BaseViewController ()

@end

@implementation BaseViewController
@synthesize m_bgView, m_contentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    CLS_LOG(@"%@ viewDidLoad:", [[self class] description]);
    
    //+++Loc Cao
    //Assign correct size for view (different for iphone/ipad)
    CGRect rect = self.view.frame;
    rect.size.width = [[UIScreen mainScreen] bounds].size.width;
    rect.size.height = [[UIScreen mainScreen] bounds].size.height;
    self.view.frame = rect;
    //---
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.m_bgView = bgView;
    [self.view addSubview:self.m_bgView];
    [self.view sendSubviewToBack:self.m_bgView];
    
    // Initialize
    [self initializeVariables];
    [self initializeScreen];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:[self shouldHideNavigationBar]];
    [self.navigationController setToolbarHidden:[self shouldHideToolBar]];
    
    self.navigationController.navigationBar.barTintColor = kCabColorAll;
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.tintColor = kWhiteColor;
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kWhiteColor, UITextAttributeTextColor, [UIFont boldSystemFontOfSize:kFontSizeNormal], UITextAttributeFont,nil]];
    
    // Update current orientation
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        currentOrientationMask = UIInterfaceOrientationMaskLandscapeRight;
        if ([self shouldRelayoutBeforeRotation])
            if (self.view.frame.size.width < self.view.frame.size.height)
                self.view.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
    } else {
        currentOrientationMask = UIInterfaceOrientationMaskPortrait;
        if ([self shouldRelayoutBeforeRotation])
            if (self.view.frame.size.width > self.view.frame.size.height)
                self.view.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
    }
    
    if ([self shouldRelayoutBeforeViewAppear]) {
        [self relayout];
    }
}
#pragma GCC diagnostic pop

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CLS_LOG(@"%@ viewDidAppear:", [[self class] description]);
    
    // Fix bug #536: All screens are not relayout after it backs from Passcode Screen. Should rotate after view did appear.
    [self relayout];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    CLS_LOG(@"%@ viewDidDisappear:", [[self class] description]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Auto rotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return ![CommonVar lockedOrientation]; //toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotate {
    return ![CommonVar lockedOrientation];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	return UIInterfaceOrientationPortrait;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self relayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if (UIInterfaceOrientationIsPortrait(fromInterfaceOrientation)) {
        currentOrientationMask = UIInterfaceOrientationMaskLandscapeRight;
    } else {
        currentOrientationMask = UIInterfaceOrientationMaskPortrait;
    }
    
    // Relayout view/view controllers
    [self relayout];
}

- (BOOL)isLandscapeMode {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return NO;
    
    return !UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
}

#pragma mark -
- (BOOL)shouldHideNavigationBar {
    return YES;
}

- (BOOL)shouldHideToolBar {
    return YES;
}

- (BOOL)shouldHideFooterView {
    return YES;
}

- (BOOL)shouldRelayoutBeforeViewAppear {
    return YES;
}

- (void)initializeVariables {
    // TODO on childs
    self.shouldRefreshUIOnBack = NO;
}

- (void)initializeScreen {
    // TODO on childs
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ID_BACK", @"") style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:newBackButton];
}

- (void)initFooterView {
    // TODO on childs
}

- (void)relayout {
    // TODO on childs
    if (self.loadingView) {
        self.loadingView.frame = self.view.bounds;
    }
}

- (BOOL)shouldRelayoutBeforeRotation {
    return YES;
}

- (void)loadDataForMe:(id)dummy threadObj:(id<ThreadProtocol>)threadObj {
    [threadObj releaseOperation];
}

- (void)reloadViewController
{
    // TOTO on childs
}

- (void)stopAllTaskBeforeQuit {
    [[EventManager getInstance] removeListener:self channel:CHANNEL_DATA];
}

#pragma mark - Button events
- (void)handleBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
