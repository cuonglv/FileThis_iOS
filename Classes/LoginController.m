//
//  LoginController.m
//  FTMobile
//
//  Created by decuoi on 11/21/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
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
#import "LoginController.h"
#import "RootViewController.h"
#import "SignupViewController.h"
#import "ConnectionViewController.h"

#import "MyAnimatedView.h"
#import "Constants.h"
#import "CommonFunc.h"
#import "CommonVar.h"
#import "TagController.h"
#import "DocumentController.h"
#import "Layout.h"

#import "DestinationPickerViewController.h"
#import <Crashlytics/Crashlytics.h>

typedef enum {
    LOGIN_SECTION,
    SIGN_IN_SECTION,
    CREATE_NEW_ACCOUNT_SECTION,
    DEBUG_SECTION
} LoginSections;

typedef enum {
    HOST_NAME_CELL
} DebugSectionCells;

@interface LoginController () <UITextFieldDelegate, UITableViewDelegate> {
    MyAnimatedView *animatedView;
    
    UIImageView *imvSplashScreen;
    
    IBOutlet UIView *vwLogin;
    
    //just for test speed
    MyLabel *lblPageSize, *lblCacheThumbSmallCount;
    MyTextField *tfPageSize, *tfCacheThumbSmallCount;
        
    EnterPasscodeView *vwEnterPasscode;
    
    int iPasscodeEnterCount;
    
    BOOL blnFirstLoad;
}

@property (weak, nonatomic) IBOutlet UILabel *versionView;

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

@implementation LoginController

- (void)awakeFromNib
{
    blnFirstLoad = YES;
    vwEnterPasscode = nil;
    iPasscodeEnterCount = 0;
}

- (void)dealloc
{
    NSLog(@"disposing of %@", self);
}

- (void)setBackgroundForOrientation:(UIDeviceOrientation)orientation {
    NSString *launchImageName = @"Default";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {        
        launchImageName = UIDeviceOrientationIsLandscape(orientation) ?
        @"Default-Landscape" : @"Default-Portrait";
    }
    UIImage *image = [UIImage imageNamed:launchImageName];
    UIImageView *bgView = (UIImageView *) self.tableView.backgroundView;
    if ([bgView respondsToSelector:@selector(image)])
        if (bgView.image == image)
            return;
        
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:image];    
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self setBackground];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    // build version string from CFBundleShortVersionString (Version) and CFBundleVersion (Build).
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *versionStr = [NSString stringWithFormat:@"v%@ (%@)",
                            [appInfo objectForKey:@"CFBundleShortVersionString"],
                            [appInfo objectForKey:@"CFBundleVersion"]];
    self.versionView.text = versionStr;
    
    vwLogin.hidden = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ping:) name:FTPing object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    CLS_LOG(@"LoginController viewWillAppear:");
    self.warningsView.text = nil;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:YES animated:YES];
    if ([FTSession sharedSession].loginDisabled)
        [self lockdownWithMessage:NSLocalizedString(@"Logging in…", @"autologin message")];
    else
        [self enableLogin:YES];
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationUnknown)
        orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    [self setBackgroundForOrientation:orientation];
    
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
    
    return [super viewWillAppear:animated];
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

- (void)endSplashScreen {
    CABasicAnimation *animSplash = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animSplash.duration = 0.25;
    animSplash.removedOnCompletion = NO;
    animSplash.fillMode = kCAFillModeForwards;
    animSplash.toValue = @0.0f;
    animSplash.delegate = self;
    [imvSplashScreen.layer addAnimation:animSplash forKey:@"animateOpacity"];
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
    if ([self.usernameField isFirstResponder])
        [self.usernameField resignFirstResponder];
    if ([self.passwordField isFirstResponder])
        [self.passwordField resignFirstResponder];
    
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

- (void)loadConnections {
    [[FTSession sharedSession] startup];
    [self performSegueWithIdentifier:@"GoHome" sender:self];
}

- (void)handleLoginResponse:(id)json {
    NSLog(@"handling login response %@", json);
    if ([[FTSession sharedSession] validateLoginResponse:json]) {
        // clear login fields
#if !AUTO_LOGIN
        self.usernameField.text = @"";
        self.passwordField.text = @"";
#endif
        [self loadConnections];
    } else {
        // TODO: extract warnings message from request object
        self.warningsView.text = [self warningForLoginError:json];
        self.warningsView.textColor = [UIColor redColor];
        [self enableLogin:YES];
        [self.activityIndicator stopAnimating];
        [self.tableView reloadData];
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

#pragma mark -
#pragma mark TextFieldDelegate
/*- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return YES;
}*/
/*
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([textField canResignFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}*/

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    for (UITouch *touch in touches) {
//        CGPoint point = [touch locationInView:self.view];
//        if ([tfUser isEditing]) {
//            if ([Layout isPointOutsideControl:point forControl:tfUser]) {
//                [tfUser endEditing:YES];
//                return;
//            }
//        }
//        if ([tfPass isEditing]) {
//            if ([Layout isPointOutsideControl:point forControl:tfPass]) {
//                [tfPass endEditing:YES];
//                return;
//           }
//        }
//        if ([tfPageSize isEditing]) {
//            if ([Layout isPointOutsideControl:point forControl:tfPageSize]) {
//                [tfPageSize endEditing:YES];
//                return;
//            }
//        }
//        if ([tfCacheThumbSmallCount isEditing]) {
//            if ([Layout isPointOutsideControl:point forControl:tfCacheThumbSmallCount]) {
//                [tfCacheThumbSmallCount endEditing:YES];
//                return;
//            }
//        }
//    }
//}
//
- (void)gotoDocumentScreen {
    blnFirstLoad = NO;
    [CommonVar setRequestURL:[kServer stringByAppendingFormat:@"json=true&compact=false&ticket=%@&op=", [CommonVar ticket]]];
    DocumentController *dc = [[DocumentController alloc] initWithNibName:@"DocumentController" bundle:[NSBundle mainBundle]];
    [CommonVar setDocCon:dc];
    [self.navigationController pushViewController:dc animated:YES];
}

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

//- (BOOL)authenticateLoginResponse:(NSData *)data {
//    BOOL authenticated = NO;
//    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//    NSLog(@"Login received data:%@", responseString);
//    if ([responseString length] > 0) {
//        NSRange range1 = [responseString rangeOfString:@"("];
//        NSRange range2 = [responseString rangeOfString:@")"];
//        if (range1.length > 0 && range2.length > 0) {
//            NSString *substring = [[responseString substringToIndex:range2.location] substringFromIndex:range1.location + 1];
//            NSDictionary *dict = [CommonFunc jsonDictionaryFromString:substring];
//            if (dict) {
//                if ([[dict valueForKey:@"result"] isEqualToString:@"OK"]) { //if there is result key
//                    NSString *nextString = [[NSURL URLWithString:[dict objectForKey:@"next"]] query];
//                    NSString *s = [nextString substringFromIndex:[nextString rangeOfString:@"ticket="].location + 7];
//                    NSString *ticket = [[NSString alloc] initWithString:s];
//                    [[FTSession sharedSession] setTicket:ticket];
//                    [CommonVar setTicket:ticket];
//                    [ticket release];
//                    [CommonVar savePlist];
//                    
//                    authenticated = YES;
//                }
//            }
//        }
//    }
//    [responseString release];
//    
//    return authenticated;
//}
//
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

- (IBAction)cancel:(UIStoryboardSegue *)segue
{
    NSLog(@"cancelled %@ from %@ to %@", segue.identifier, segue.sourceViewController, segue.destinationViewController);
}

- (IBAction)logout:(UIStoryboardSegue *)segue
{
    [[FTSession sharedSession] logout];
    NSLog(@"logout %@ from %@ to %@", segue.identifier, segue.sourceViewController, segue.destinationViewController);
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

#pragma mark - UITableViewDelegate methods


-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == DEBUG_SECTION) {
        switch (indexPath.row) {
            case HOST_NAME_CELL:
                [self pickServer];
                break;
        }
    }
    return NO;
}

#ifndef DEBUG
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
#endif

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    self.loginTableCellView = nil; // regenerate for new orientation
    [self setBackgroundForOrientation:[UIDevice currentDevice].orientation];
}


//// custom view for footer. will be adjusted to default or specified footer height
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section == 1)
//    {
//        return [tableView heightForButton];
//    }
//    return 0.0;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if (section == 1)
//    {
//        if (self.loginTableCellView == nil) {
//            NSString *title = NSLocalizedString(@"Sign In", @"Login button");
//            self.loginButton = [UIButton makeButtonWithTitle:title withTarget:self action:@selector(login:)];
//            self.loginTableCellView = [tableView makeFooterViewForButton:self.loginButton];
//            // make activity indicator
//            CGRect frame = self.loginButton.frame;
//            frame.size.width = frame.size.height; // make a square
//            frame.origin.x = self.loginButton.frame.origin.x + self.loginButton.frame.size.width - frame.size.width;
////            frame = CGRectInset(frame, CGRectGetMidX(frame) - 20, 0);
//            self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:frame];
//            self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
//            self.activityIndicator.color = [UIColor blueColor];
//            self.activityIndicator.hidesWhenStopped = YES;
//            [self.activityIndicator stopAnimating];
//            self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin + UIViewAutoresizingFlexibleRightMargin;
//            [self.loginTableCellView bringSubviewToFront:self.activityIndicator];
//            [self.loginTableCellView addSubview:self.activityIndicator];
//        }
//        
//        [self enableLoginIfComplete];
//        
//        return self.loginTableCellView;
//    }
//    return nil;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    if (section == 1) {
//        return [tableView heightForButton];
//    }
//    return 0.0;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    switch (section) {
//        case 1:
//        {
//            NSString *title = NSLocalizedString(@"Create New Account", @"Create New Account button on Login page");
//            UIButton *button = [UIButton makeButtonWithTitle:title withTarget:self action:@selector(createAccount:)];
//            return [tableView makeFooterViewForButton:button];
//            break;
//        }
//        case 2:
//            break;
//    }
//    return nil;
//}

//    if (section == 0) { // create view to hold Warnings and activity
//        if (self.warnings.length > 0) {
//            // FIXME: inset values differ from iPhone and iPad
//            UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
//            CGRect frame = CGRectMake(0, 0, tableView.frame.size.width,
//                                      tableView.rowHeight + edgeInsets.top + edgeInsets.bottom );
//            view = [[UIView alloc] initWithFrame:frame];
//            view.autoresizingMask |= UIViewAutoresizingFlexibleWidth;
//            view.autoresizesSubviews = YES;
//            //        view.backgroundColor = [UIColor redColor];
//            self.warningsView = [[UILabel alloc] initWithFrame:frame];
//            self.warningsView.textColor = [UIColor redColor];
//            self.warningsView.textAlignment = NSTextAlignmentCenter;
//            self.warningsView.autoresizingMask |= UIViewAutoresizingFlexibleWidth;
//            self.warningsView.text = @"XXXYXYXYXYXYXYXYXYXYXYXY";
//            // do button set up here, including sizing and centering, and add to footer view
//            [view addSubview:self.warningsView];
//        }
//    } else

#pragma mark UIKeyboard notifications

// http://stackoverflow.com/questions/5265559/get-uitableview-to-scroll-to-the-selected-uitextfield-and-avoid-being-hidden-by
- (void)keyboardWillShow:(NSNotification *)sender
{
    CGSize kbSize = [[[sender userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
        [self.tableView setContentInset:edgeInsets];
        [self.tableView setScrollIndicatorInsets:edgeInsets];
    }];
}

- (void)keyboardWillHide:(NSNotification *)sender
{
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
        [self.tableView setContentInset:edgeInsets];
        [self.tableView setScrollIndicatorInsets:edgeInsets];
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

#pragma mark KKPasscodeViewControllerDelegate methods

- (void)didPasscodeEnteredCorrectly:(KKPasscodeViewController*)viewController {
    [self loadConnections];
}

- (void)didPasscodeEnteredIncorrectly:(KKPasscodeViewController*)viewController {
        [self dismissViewControllerAnimated:YES completion:nil];
}

@end
