//
//  NewLoginViewController.m
//  FileThis
//
//  Created by Cuong Le on 11/14/13.
//
//


#import <QuartzCore/QuartzCore.h>
#import "Foundation/NSJSONSerialization.h"

#import "UIKitExtensions.h"

#import "ServerPickerViewController.h"
#import "DestinationConfirmationViewController.h"
#import "FTSession.h"
#import "FTMobileAppDelegate.h"
#import "FTDestinationConnection.h"

#import "KKPasscodeLock.h"
#import "KKPasscodeViewController.h"
#import "NewLoginViewController.h"
#import "RootViewController.h"
#import "SignupViewController.h"
#import "ConnectionViewController.h"

#import "Constants.h"
#import "CommonFunc.h"
#import "CommonVar.h"
#import "TagController.h"
#import "DocumentController.h"
#import "Layout.h"

#import "DestinationPickerViewController.h"
#import <Crashlytics/Crashlytics.h>
#import "CommonLayout.h"

@interface NewLoginViewController () <UITextFieldDelegate, UITableViewDelegate> {

}

@property (strong, nonatomic) IBOutlet UIScrollView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *versionView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *loginButton, *createNewAccountButton;
@property (weak, nonatomic) IBOutlet UILabel *warningsView;
@property (strong) UIView *loginTableCellView;
@property (readonly) NSString *username;
@property (readonly) NSString *password;
@property NSString *authenticationString;
@property id observer;
@property (weak, nonatomic) IBOutlet UILabel *serverName;

@end

@implementation NewLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    float y;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        y = kIOS7ToolbarHeight;
    } else
        y = 0;

    self.containerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height - y)];
    self.containerView.contentSize = CGSizeMake(self.containerView.frame.size.width, self.containerView.frame.size.height + 500);
    self.containerView.scrollEnabled = NO;
    [self.view addSubview:self.containerView];
    
    float logoWidth = 250;
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - logoWidth)/2, 40, logoWidth, 60)];
    logoImageView.image = [UIImage imageNamed:@"FetchLogo_Text.png"];
    [CommonLayout autoImageViewHeight:logoImageView];
    [self.containerView addSubview:logoImageView];
    
    UIImageView *boxImageView = [[UIImageView alloc] initWithFrame:[logoImageView rectAtBottom:20 width:260 height:46]];
    boxImageView.image = [UIImage imageNamed:@"textfield_background.png"];
    [self.containerView addSubview:boxImageView];
    
    self.usernameField = [CommonLayout createTextField:CGRectMake(boxImageView.frame.origin.x+15, boxImageView.frame.origin.y+1, boxImageView.frame.size.width-17, 44) fontSize:FontSizeMedium isBold:NO textColor:[UIColor colorWithRed:0.17 green:0.42 blue:0.63 alpha:1.0] backgroundColor:nil text:@"" superView:self.containerView];
    self.usernameField.borderStyle = UITextBorderStyleNone;
    self.usernameField.placeholder = @"Email";
    self.usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.usernameField.keyboardType = UIKeyboardTypeEmailAddress;
    self.usernameField.returnKeyType = UIReturnKeyNext;
    self.usernameField.tag = 1;
    self.usernameField.delegate = self;
    
    boxImageView = [[UIImageView alloc] initWithFrame:[boxImageView rectAtBottom:4 height:boxImageView.frame.size.height]];
    boxImageView.image = [UIImage imageNamed:@"textfield_background.png"];
    [self.containerView addSubview:boxImageView];
    
    self.passwordField = [CommonLayout createTextField:CGRectMake(boxImageView.frame.origin.x+15, boxImageView.frame.origin.y+1, boxImageView.frame.size.width-17, 44) fontSize:FontSizeMedium isBold:NO textColor:self.usernameField.textColor backgroundColor:nil text:@"" superView:self.containerView];
    self.passwordField.borderStyle = UITextBorderStyleNone;
    self.passwordField.placeholder = @"Password";
    self.passwordField.secureTextEntry = YES;
    self.passwordField.returnKeyType = UIReturnKeyDone;
    self.passwordField.tag = 2;
    self.passwordField.delegate = self;
    
    self.warningsView = [CommonLayout createLabel:[self.passwordField rectAtBottom:8 height:25] fontSize:FontSizeSmall isBold:NO textColor:[UIColor redColor] backgroundColor:nil text:@"" superView:self.containerView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ping:) name:FTPing object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    CLS_LOG(@"LoginController viewWillAppear:");
    
    self.warningsView.text = nil;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    if ([FTSession sharedSession].loginDisabled)
        [self lockdownWithMessage:NSLocalizedString(@"Logging in…", @"autologin message")];
    else
        [self enableLogin:YES];
    
    if (lastSignedUpEmail_) {
        self.usernameField.text = lastSignedUpEmail_;
        self.passwordField.text = lastSignedUpPassword_;
    } else {
        NSString *serverName = [FTSession hostName];
        self.serverName.text = serverName;
#if AUTO_LOGIN
        // get last login credentials
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *userObject = [defaults objectForKey:serverName];
        if (userObject) {
            self.usernameField.text = [userObject objectForKey:@"username"];
            self.passwordField.text = [userObject objectForKey:@"password"];
        }
#endif
    }
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (self.view.frame.size.height <= 500) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        }
    }
    return [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    CLS_LOG(@"LoginController viewWillDisappear:");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
    [super viewDidDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GoHome"])
    {
        // nothing to do 
    } else if ([segue.identifier isEqualToString:@"LoginDestinationPicker"]) {
        DestinationPickerViewController *picker = segue.destinationViewController;
        picker.hidesBackButton = YES;
        picker.firstTime = YES;
    } else if ([segue.identifier isEqualToString:@"confirmDestinationAuthentication"]) {
        DestinationConfirmationViewController *w = segue.destinationViewController;
        int destinationId = [FTSession sharedSession].currentDestination.destinationId;
        w.destinationId = destinationId;
        [w.navigationController setNavigationBarHidden:NO animated:YES];
        w.authenticationString = self.authenticationString;
        w.firstTime = YES;
        w.alertUser = YES;
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(BOOL)shouldAutorotate {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? NO : YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ?UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown
    : UIInterfaceOrientationMaskAll;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (NSString *)username {
    return self.usernameField.text;
}

- (NSString *)password {
    return self.passwordField.text;
}

static NSString *lastSignedUpEmail_ = nil;
+ (void)setLastSignedUpEmail:(NSString*)val {
    lastSignedUpEmail_ = val;
}

static NSString *lastSignedUpPassword_ = nil;
+ (void)setLastSignedUpPassword:(NSString*)val {
    lastSignedUpPassword_ = val;
}

#pragma mark - Actions

/*
 
 The Login sequence is a little complicated, because the required actions
 (i.e. authenticate and then verify destination) are not atomic.
 
 When a user first signs up, they have to
 1. confirm their email (this is archaic. who uses email anymore?)
 2. login once they've confirmed their email.
 <-> auth
 <-> load their current destination
 3. if no current destination...
 <-> load all destinations
 4. display a picker window of all destinations...
 5. authenticate with their destination using oauth.
 
 for speed & responsiveness, perform minimal requests.
 To minimize requests, don't make them if we don't need to.
 
 // see if we need to request the destinationConnection.
 // If we've already authenticated with this account and got destination connection, we'll just
 // assume it's set.
 
 */

- (IBAction)login:(id)sender {
    if ([self.usernameField.text length] == 0) { //Cuong 10/22/2013: avoid crash
        self.warningsView.text = @"Please enter email";
        [self.usernameField becomeFirstResponder];
        return;
    }
    
    if ([self.passwordField.text length] == 0) {  //Cuong 10/22/2013: avoid crash
        self.warningsView.text = @"Please enter password";
        [self.passwordField becomeFirstResponder];
        return;
    }
    
    [[FTSession sharedSession] login:self.username withPassword:self.password onSuccess:^(id JSON) {
        [self handleLoginResponse:JSON];
    } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"login connection error=%@", error);
        self.warningsView.text = [self warningForNSError:error];
        [self enableLogin:YES];
    }];
    [self lockdownWithMessage:NSLocalizedString(@"Authenticating…", @"status shown when logging in")];
}

// now update UI, disable login, and spin activity wheel
- (void)lockdownWithMessage:(NSString *)message
{
    self.warningsView.text = message;
    self.warningsView.textColor = [UIColor blueColor];
    [self enableLogin:NO];
    [self.activityIndicator startAnimating];
}

- (void)ping:(NSNotification *)notification {
    if ([FTSession sharedSession].validated) {
        // lock UI to disable login
        [self lockdownWithMessage:NSLocalizedString(@"Resuming…", @"message shown while resuming")];
        // load home screen
        [[FTSession sharedSession] startup];
        [self performSegueWithIdentifier:@"GoHome" sender:self];
    } else {
        NSError *error = notification.object;
        [[FTSession sharedSession] presentError:error withTitle:@"FileThis Autologin Failed"];
        
        //        NSString *m = nil;
        //        NSString *recoverySuggestion = error.localizedRecoverySuggestion;
        //        if (recoverySuggestion != nil) {
        //            NSRange is503 = [recoverySuggestion rangeOfString:@"got 503"];
        //            if (is503.location != NSNotFound)
        //                m = @"Server is unavailable";
        //            else
        //                m = recoverySuggestion;
        //        } else {
        //            NSString *format = NSLocalizedString(@"Server could not be reached. %@", @"Ping failed because Server could not be reached.");
        //            m = [NSString stringWithFormat:format, error.localizedDescription];
        //        }
        //        [[[UIAlertView alloc] initWithTitle:@"FileThis Error" message:m delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        self.warningsView.text = nil;
        [self enableLogin:YES];
    }
}

- (void)handleLoginResponse:(id)json {
    NSLog(@"handling login response %@", json);
    if ([[FTSession sharedSession] validateLoginResponse:json]) {
        // clear login fields
#if !AUTO_LOGIN
        self.usernameField.text = @"";
        self.passwordField.text = @"";
#endif
        [(FTMobileAppDelegate*)[UIApplication sharedApplication].delegate loadConnections];
    } else {
        // TODO: extract warnings message from request object
        self.warningsView.text = [self warningForLoginError:json];
        self.warningsView.textColor = [UIColor redColor];
        [self enableLogin:YES];
        [self.activityIndicator stopAnimating];
    }
}

/*
 Parse response from bad login:
 {
 error =     {
 text = "Account hasn't been verified. If you have not received your email verification, please check your junk and spam folders for this email. If you cannot find it, click <a href='https://staging.filethis.com/ftapi/ftapi?op=accountResendCode&email=ftd2@mailinator.com' onclick='myJSFunc(); return false;' target='_blank'><b>HERE</b></a> to have it resent to you. If you still do not receive it, send us an <a href='mailto:support@filethis.com?subject=Resend%20email%20verification';>email</a> with your email address.";
 type = AccountNotVerifiedException;
 };
 result = ERROR;
 }
 */
- (NSString *)warningForLoginError:(NSDictionary *)error
{
    NSAssert1([error[@"result"] isEqualToString:@"ERROR"],
              @"response.result should be ERROR, not %@", error[@"result"]);
    
    NSString *warning = @"Invalid Login";
    NSString *title;
    NSString *message;
    NSString *errorType = error[@"error"][@"type"];
    
    if ([errorType isEqualToString:@"AccountNotVerifiedException"]) {
        title = warning = @"Email not verified";
        message = @"Your email has not been verified. Please check your email and accept the link we sent to your email address." ;
    } else if ([errorType isEqualToString:@"BadPasswordException"]) {
        title = @"Wrong Password";
        message = error[@"error"][@"text"];
        warning = @"Wrong password";
    } else if ([errorType isEqualToString:@"UnknownUserException"]) {
        title = @"Invalid Login";
        message = error[@"error"][@"text"];
        warning = @"Unknown user";
    }
    if (title != nil) {
        dispatch_block_t block = ^{
            [[[UIAlertView alloc] initWithTitle:title
                                        message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil ] show];
        };
        runOnMainQueueWithoutDeadlocking(block);
    }
    
    return warning;
}

- (NSString *)warningForNSError:(NSError *)error
{
    NSString *warning = [error fileThisUserMessage];
    NSString *title = NSLocalizedString(@"Cannot Login", @"title of alert when login fails");
    dispatch_block_t block = ^{
        [[[UIAlertView alloc] initWithTitle:title
                                    message:warning delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    };
    runOnMainQueueWithoutDeadlocking(block);
    
    return warning;
}

- (IBAction)showCreateAccount:(id)sender {
    SignupViewController *vc = [[SignupViewController alloc] initWithNibName:@"SignupViewController" bundle:nil];
    vc.view.autoresizesSubviews = NO;
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    // NOTE: wanted to use UIModalTransitionStyleFlipHorizontal
    // but iOS 6 prevents this transition from working properly using the hack of
    // setting the superview bounds.
    // http://stackoverflow.com/questions/12563798/error-to-present-view-controller-centered-in-ipad-ios-6
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    CGRect bounds = vc.view.bounds;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        bounds.size.width = 340;
        bounds.size.height = 330;
        vc.view.bounds = bounds;
        NSLog(@"setting center to %@", NSStringFromCGPoint(vc.view.center));
    }
    [self presentViewController:vc animated:YES completion:nil];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        bounds.origin.y += 80;
        vc.view.superview.bounds = bounds;
    }
}

#pragma mark - TextFieldDelegate
- (void)gotoConnectionsView {
    // hide us
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"presenting vs is %@", self.presentingViewController);
    NSLog(@"presented vc is %@", self.presentedViewController);
    
    UIViewController *pvc = nil;
    if ([self.presentingViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navC = (UINavigationController *) self.presentingViewController;
        NSLog(@"visible vc is %@", navC.visibleViewController);
        pvc = navC.visibleViewController;
        for (UIViewController *vc in navC.viewControllers) {
            if ([vc isKindOfClass:[RootViewController class]]) {
                pvc = vc;
                break;
            }
        }
    } else if ([self.presentingViewController isKindOfClass:[RootViewController class]]) {
        pvc = self.presentingViewController;
    } else {
        NSAssert1(NO, @"unknown type for presenting view controller %@", self.presentingViewController);
    }
    
    [pvc performSelector:@selector(pushConnectionView) withObject:nil afterDelay:0.2];
}

// Parse the individual parameters
// parameters = @"hello=world&foo=bar";
- (id) getValueFromQueryString:(NSString *)query withField:(NSString *) fieldName {
    NSArray *arrParameters = [query componentsSeparatedByString:@"&"];
    for (int i = 0; i < [arrParameters count]; i++) {
        NSArray *arrKeyValue = [arrParameters[i] componentsSeparatedByString:@"="];
        if ([arrKeyValue count] >= 2) {
            NSString *keyName = arrKeyValue[0];
            if ([keyName isEqualToString:fieldName])
                return arrKeyValue[1];
        }
    }
    return NULL;
}

- (IBAction)createNewAccount:(id)sender {
    [self performSegueWithIdentifier:@"createNewAccount" sender:sender];
}

- (IBAction)signupDismissed:(id)sender {
#ifdef DEBUG
    NSLog(@"modal presentation: %d, transition: %d", self.modalPresentationStyle, self.modalTransitionStyle);
    for (UIViewController *vc in self.navigationController.viewControllers)
    {
        NSLog(@"Navigation stack: %@", vc);
    }
#endif
    [self.navigationController popToViewController:self animated:YES];
}

- (IBAction)accountCreated:(UIStoryboardSegue *)segue
{
    SignupViewController *signup = segue.sourceViewController;
    self.usernameField.text = signup.email;
    self.passwordField.text = signup.password;
}

- (IBAction)unwindToOnboard:(UIStoryboardSegue *)unwindSegue
{
    
}

- (IBAction)cancel:(UIStoryboardSegue *)segue
{
    NSLog(@"cancelled %@ from %@ to %@", segue.identifier, segue.sourceViewController, segue.destinationViewController);
}

- (BOOL)enableLogin:(BOOL)enable
{
    if ([FTSession sharedSession].loginDisabled)
        enable = NO;
    self.loginButton.alpha = enable ? 1.0 : 0.5;
    self.loginButton.enabled = enable;
    if (enable) {
        [self.activityIndicator stopAnimating];
    }
    return enable;
}

- (BOOL)enableLoginIfComplete
{
    int numEmpty = 0;
    for (UITextField *field in @[self.usernameField, self.passwordField]) {
        if (field.text == nil || field.text.length == 0)
            numEmpty++;
    }
    if (![self.usernameField.text isValidEmail])
        numEmpty++;
    if (![self.passwordField.text isValidPassword])
        numEmpty++;
    
    return [self enableLogin: numEmpty == 0];
}

- (void)pickServer {
    ServerPickerViewController *vc = [[ServerPickerViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark UIKeyboard notifications
// http://stackoverflow.com/questions/5265559/get-uitableview-to-scroll-to-the-selected-uitextfield-and-avoid-being-hidden-by
- (void)keyboardWillShow:(NSNotification *)sender {
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.containerView.contentOffset = CGPointMake(0,40);
    }];
}

- (void)keyboardWillHide:(NSNotification *)sender {
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.containerView.contentOffset = CGPointMake(0,0);
    }];
}

#pragma mark UITextFieldDelegate methods
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self enableLoginIfComplete];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // validate fields after editing change takes affect
    [self performSelector:@selector(enableLoginIfComplete) withObject:nil afterDelay:0.0];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self performSelector:@selector(enableLoginIfComplete) withObject:nil afterDelay:0.0];
    return YES;
}

// ref http://stackoverflow.com/questions/1347779/how-to-navigate-through-textfields-next-done-buttons
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    int previousTag = textField.tag, numberOfRows = 100;
    if (previousTag <= numberOfRows) {
        UITextField *nextField=(UITextField *)[self.view viewWithTag:previousTag+1];
        if (nextField == nil)
        {
            // no next - so remove keyboard
            [textField resignFirstResponder];
            // and login
            [self login:nil];
        } else {
            [nextField becomeFirstResponder];
        }
    }
    return YES;
}

@end
