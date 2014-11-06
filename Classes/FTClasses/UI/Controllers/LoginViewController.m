//
//  LoginViewController.m
//  FileThis
//
//  Created by Manh nguyen on 1/1/14.
//
//

#import "LoginViewController.h"
#import "CommonLayout.h"
#import "ServerPickerViewController.h"
#import "FTSession.h"
#import "CommonFunc.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeScreen {
    [super initializeScreen];
    
#ifdef DEBUG
    self.serverNameLabel = [CommonLayout createLabel:CGRectMake(self.view.frame.size.width/2-self.centerView.frame.size.width/2,self.view.frame.size.height-80, self.centerView.frame.size.width, 35) fontSize:FontSizeSmall isBold:NO textColor:[UIColor blueColor] backgroundColor:[UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0] text:@"" superView:self.view];
    self.serverNameLabel.textAlignment = NSTextAlignmentCenter;
    self.serverNameLabel.layer.borderColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0].CGColor;
    self.serverNameLabel.layer.borderWidth = 1.0;
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *userName = [CommonFunc getUsername];
    if (userName != nil) {
        [self.centerView.loginView.txtEmail setText:userName];
    }
#ifdef DEBUG
    NSString *defaultHostname = [ServerPickerViewController configurations][0];
    NSString *currentHostName = [FTSession hostName];
    if ([currentHostName isEqualToString:defaultHostname])
        self.serverNameLabel.text = @"";
    else
        self.serverNameLabel.text = [NSString stringWithFormat:@"Connecting to %@", currentHostName];
#endif
}

- (void)viewWillLayoutSubviews {
    [self relayout];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldRelayoutBeforeViewAppear
{
    return NO;
}

#pragma mark - Layout
- (void)relayout {
    [super relayout];
    
    self.bgPage.frame = self.view.bounds;
    [self relayout_device]; //Different for iphone/ipad
}

- (void)relayout_device {
    CGRect rect = self.centerView.frame;
    rect.origin.x = self.view.bounds.size.width/2 - rect.size.width/2;
    rect.origin.y = self.view.bounds.size.height/2 - rect.size.height/2;
    self.centerView.frame = rect;
    
#ifdef DEBUG
    rect = self.serverNameLabel.frame;
    rect.origin.x = (self.view.frame.size.width - rect.size.width) / 2.0;
    rect.origin.y = self.view.frame.size.height - rect.size.height - 10;
    self.serverNameLabel.frame = rect;
#endif

    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[ForgotPasswordPopupView class]]) {
            v.frame = self.view.bounds;
        }
    }
    
    BOOL showingKeyboard = [self.centerView isInputingText];
    [self layoutCenterSideView:showingKeyboard];
}

- (void)layoutCenterSideView:(BOOL)isShowKeyboard
{
    if ( (self.interfaceOrientation != UIInterfaceOrientationLandscapeLeft)
        && (self.interfaceOrientation != UIInterfaceOrientationLandscapeRight) )
        return;
    
    CGRect rect = self.centerView.frame;
    rect.origin.x = self.view.bounds.size.width/2 - rect.size.width/2;
    rect.origin.y = self.view.bounds.size.height/2 - rect.size.height/2;
    
    if (isShowKeyboard)
    {
        rect.origin.y -= 140;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.centerView.frame = rect;
    }];
}

#pragma mark - Touch events
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self.centerView cancelInputingText];
}

#pragma mark - Keyboard show/hide
- (void)keyboardWillShow:(NSNotification *)notification
{
    [self layoutCenterSideView:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self layoutCenterSideView:NO];
}

#pragma mark - MyFunc

@end
