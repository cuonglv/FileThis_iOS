//
//  LoginView.m
//  FileThis
//
//  Created by Manh nguyen on 1/1/14.
//
//

#import <Crashlytics/Crashlytics.h>
#import "LoginView.h"
#import "CommonLayout.h"
#import "FTSession.h"
#import "Utils.h"
#import "FTMobileAppDelegate.h"
#import "CommonDataManager.h"
#import "LoadingView.h"
#import "CacheManager.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "ServerPickerViewController.h"

@implementation LoginView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initializeView {
    [super initializeView];
    self.loadingView = [[LoadingView alloc] init];
    [LoadingView setCurrentLoadingView:self.loadingView];
    [LoadingView setCurrentLoadingViewContainer:self.superview.superview];
    
    self.imgLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FetchLogo_Text.png"]];
    [self.imgLogo setFrame:CGRectMake(60, 30, 250, 70)];
    [self addSubview:self.imgLogo];
    
    self.lblLogin = [CommonLayout createLabel:[self.imgLogo rectAtBottom:40 height:30] fontSize:kFontSizeNormal isBold:YES textColor:kDarkGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_LOGIN_TO_FILETHIS", @"") superView:self];
    [self.lblLogin setTextAlignment:NSTextAlignmentCenter];
    
    self.txtEmail = [[BorderTextField alloc] initWithFrame:CGRectMake(30, [self.lblLogin bottom] + 10, self.frame.size.width - 60, 30)];
    [self.txtEmail setPlaceholder:NSLocalizedString(@"ID_ENTER_EMAIL", @"")];
    [self.txtEmail setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal]];
    [self.txtEmail setBorderStyle:UITextBorderStyleNone];
    [self.txtEmail setClearButtonMode:UITextFieldViewModeWhileEditing];
    self.txtEmail.delegate = self;
    self.txtEmail.keyboardType = UIKeyboardTypeEmailAddress;
    self.txtEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.txtEmail.autocorrectionType = UITextAutocorrectionTypeNo;
    [self addSubview:self.txtEmail];
    
    self.txtPassword = [[BorderTextField alloc] initWithFrame:[self.txtEmail rectAtBottom:10 height:30]];
    [self.txtPassword setPlaceholder:NSLocalizedString(@"ID_PASSWORD", @"")];
    [self.txtPassword setBorderStyle:UITextBorderStyleNone];
    [self.txtPassword setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal]];
    [self.txtPassword setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.txtPassword setSecureTextEntry:YES];
    [self.txtPassword setReturnKeyType:UIReturnKeyGo];
    self.txtPassword.enablesReturnKeyAutomatically = YES;
    self.txtPassword.delegate = self;
    [self addSubview:self.txtPassword];
    
    self.btnForgotPassword = [CommonLayout createTextButton:CGRectMake([self.txtPassword left], [self.txtPassword bottom] + 10, self.txtEmail.frame.size.width/2, 30) font:[UIFont fontWithName:@"Merriweather-Italic" size:kFontSizeNormal] text:NSLocalizedString(@"ID_FORGOT_PASSWORD_QUESTION", @"") textColor:kCabColorAll touchTarget:self touchSelector:@selector(handleForgotPasswordButton:) superView:self];
    [self.btnForgotPassword setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    self.btnLogin = [CommonLayout createTextButton:CGRectMake([self.txtPassword right] - 100, [self.txtPassword bottom] + 10, 100, 30) font:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal] text:NSLocalizedString(@"ID_LOGIN", @"") textColor:kWhiteColor touchTarget:self touchSelector:@selector(handleLoginButton:) superView:self];
    [self.btnLogin setBackgroundColor:kCabColorAll];
    
    UIView *lbl = [[UIView alloc] initWithFrame:CGRectMake(0, [self.btnLogin bottom] + 50, self.frame.size.width/2 - 25, 1)];
    [lbl setBackgroundColor:kCabColorAll];
    self.lblLine1 = lbl;
    [self addSubview:lbl];
    
    UILabel *lblOr = [[UILabel alloc] initWithFrame:CGRectMake([lbl right] + 2, [lbl top] - 10, 50, 20)];
    [lblOr setFont:[UIFont fontWithName:@"Merriweather-Bold" size:kFontSizeNormal] textColor:kGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_OR", @"") numberOfLines:0 textAlignment:NSTextAlignmentCenter];
    self.lblOr = lblOr;
    [self addSubview:lblOr];
    
    UIView *lbl1 = [[UIView alloc] initWithFrame:CGRectMake([lblOr right], [self.btnLogin bottom] + 50, self.frame.size.width/2 - 27, 1)];
    [lbl1 setBackgroundColor:kCabColorAll];
    self.lblLine2 = lbl1;
    [self addSubview:lbl1];
    
    self.btnSignUp = [CommonLayout createTextButton:CGRectMake(self.txtPassword.center.x - 100, [lbl bottom] + 20, 200, 30) font:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal] text:NSLocalizedString(@"ID_SIGNUP_A_NEW_ACC", @"") textColor:kWhiteColor touchTarget:self touchSelector:@selector(handleSignUpButton:) superView:self];
    [self.btnSignUp setBackgroundColor:kCabColorAll];
    
    self.btnLearnMore = [CommonLayout createTextButton:CGRectMake([self.btnSignUp left], self.frame.size.height - 35, self.btnSignUp.frame.size.width, 30) font:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal] text:NSLocalizedString(@"ID_LEARN_MORE", @"") textColor:kCabColorAll touchTarget:self touchSelector:@selector(handleLearnMoreButton:) superView:self];
    
    // Get latest login username
    NSString *serverName = [FTSession hostName];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [userDefault objectForKey:[NSString stringWithFormat:@"%@_latestlogininfo", serverName]];
    if (dict) {
        self.txtEmail.text = [dict objectForKey:@"username"];
    }
}

#pragma mark - Private methods
- (BOOL)enableLogin:(BOOL)enable
{
    if ([FTSession sharedSession].loginDisabled)
        enable = NO;
    return enable;
}

- (void)handleLoginResponse:(id)json {
    NSLog(@"handling login response %@", json);
    if ([[FTSession sharedSession] validateLoginResponse:json]) {
        // Keep latest login username
        NSString *serverName = [FTSession hostName];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:self.txtEmail.text forKey:@"username"];
        [dict setValue:self.txtPassword.text forKey:@"password"];
        [userDefault setObject:dict forKey:[NSString stringWithFormat:@"%@_latestlogininfo", serverName]];
        
        // clear login fields
        [self.txtEmail resignFirstResponder];
        [self.txtPassword resignFirstResponder];
        self.txtEmail.text = @"";
        self.txtPassword.text = @"";
        
        // Load connections
        [(FTMobileAppDelegate*)[UIApplication sharedApplication].delegate startLoadingData];
        
        // Load neccessary data
//        [[CommonDataManager getInstance] loadCommonData];
    } else {
        id error = [json objectForKey:@"error"];
        if (error) {
            NSString *text = [error objectForKey:@"text"];
            [CommonLayout showWarningAlert:text errorMessage:nil delegate:nil];
        }
        [self enableLogin:YES];
    }
}

#pragma mark - Button events
- (void)handleLoginButton:(id)sender {
    NSString *email = [self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //test crash
    if ([email isEqualToString:@"@crash"]) {
        [Crashlytics setUserName:email];
        [[Crashlytics sharedInstance] crash];
        return;
    }
    
    if ([email isEqualToString:@"@switchserver#planv"]) {
        [self endEditing:YES];
        ServerPickerViewController *vc = [[ServerPickerViewController alloc] initWithNibName:nil bundle:nil];
        [((FTMobileAppDelegate*)[UIApplication sharedApplication].delegate).navigationController pushViewController:vc animated:YES];
        return;
    }
    
    if ([email length] == 0 || ![Utils isValidEmail:email]) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:NSLocalizedString(@"ID_INVALID_EMAIL", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        [self.txtEmail becomeFirstResponder];
        return;
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"           // Event category (required)
                                                          action:@"button_login_press"  // Event action (required)
                                                           label:@"login"               // Event label
                                                           value:nil] build]];          // Event value

    NSString *password = [self.txtPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([password length] == 0) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:NSLocalizedString(@"ID_INVALID_PASSWORD", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        [self.txtPassword becomeFirstResponder];
        return;
    }
    
    [self.txtEmail resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    
    [self.loadingView startLoadingInView:self.superview.superview message:NSLocalizedString(@"ID_AUTHENTICATING", @"")];
    [[FTSession sharedSession] login:email withPassword:password onSuccess:^(id JSON) {
        if (![[CacheManager getInstance] isExistCacheForUsername:email]) {
            [[CacheManager getInstance] clearCacheData];
        }
        
        [self.loadingView stopLoading];
        [self handleLoginResponse:JSON];
    } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [self.loadingView stopLoading];
        NSLog(@"login connection error=%@", error);
        if (error.code == DOMAIN_ERROR_CODE) {
            [[FTSession sharedSession] handleError:error forResponse:response withTitle:@""];
        } else {
            [CommonLayout showWarningAlert:[error localizedDescription] errorMessage:nil delegate:nil];
        }
        [self enableLogin:YES];
    }];
}

- (void)handleForgotPasswordButton:(id)sender {
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://filethis.com/fetch/forgot-password/"]];
    //ForgotPasswordPopupView *forgotPasswordPopupView =
    [self cancelInputingText];
    ForgotPasswordPopupView *view = [[ForgotPasswordPopupView alloc] initWithEmail:self.txtEmail.text superView:self.superview.superview delegate:self];
    NSLog(@"%@", view);
    //[self.superview.superview addSubview:forgotPasswordPopupView];
}

- (void)handleSignUpButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didSignUpButtonTouched:)]) {
        [self.delegate didSignUpButtonTouched:self];
    }
}

- (void)handleLearnMoreButton:(id)sender {
    FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate goToCustomPagerViewController];
}


#pragma mark - WhiteRoundRectPopupViewDelegate
- (void)whiteRoundRectPopupView_ShouldCloseWithRightButtonTouched:(id)sender {
    ForgotPasswordPopupView *forgotPasswordPopupView = (ForgotPasswordPopupView*)sender;
    self.txtEmail.text = forgotPasswordPopupView.emailTextField.text;
}

#pragma mark - Layout
- (void)layoutSubviews
{
    [self.loadingView setFrame:CGRectMake(0, 0, self.superview.superview.frame.size.width, self.superview.superview.frame.size.height)];
    UIUserInterfaceIdiom idiom = UI_USER_INTERFACE_IDIOM();
    self.lblLine1.hidden = (idiom == UIUserInterfaceIdiomPhone);
    self.lblLine2.hidden = (idiom== UIUserInterfaceIdiomPhone);
    if (idiom == UIUserInterfaceIdiomPhone)
    {
        [self layoutForPhone];
    }
}

- (void)layoutForPhone
{
    CGSize size = CGSizeMake(180, 50);
    CGRect rect = CGRectMake(0, 15, size.width, size.height);
    rect.origin.x = (self.bounds.size.width - size.width) / 2.0 - 5;
    self.imgLogo.frame = rect;
    
    self.lblLogin.frame = CGRectMake(0, [self.imgLogo bottom] + 15, self.frame.size.width, 30);
    
    int margin = 10;
    int width = self.frame.size.width - 2 * margin;
    self.txtEmail.frame = CGRectMake(margin, [self.lblLogin bottom], width, 30);
    self.txtPassword.frame = [self.txtEmail rectAtBottom:10 height:30];
    
    self.btnForgotPassword.frame = [self.txtPassword rectAtBottom:5 height:30];
    size = CGSizeMake(90, 30);
    self.btnLogin.frame = CGRectMake([self.txtPassword right] - size.width, [self.btnForgotPassword top], size.width, size.height);
    
    int yLine = 246;
    rect = self.lblOr.frame;
    rect.origin.y = yLine - rect.size.height / 2;
    rect.origin.x = (self.frame.size.width - rect.size.width) / 2;
    self.lblOr.frame = rect;
    
    rect = self.btnSignUp.frame;
    rect.origin.x = (self.frame.size.width - rect.size.width) / 2;
    rect.origin.y = [self.lblOr bottom] + 10;
    self.btnSignUp.frame = rect;
    
    int yButton = 319;
    self.btnLearnMore.frame = CGRectMake(0, yButton, self.frame.size.width, self.frame.size.height - yButton);
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.txtEmail) {
        [self.txtPassword becomeFirstResponder];
    } else if (textField == self.txtPassword) {
        [self handleLoginButton:self.btnLogin];
    }
    
    return YES;
}

#pragma mark - Public methods
- (BOOL)isInputingText
{
    if ([self.txtEmail isFirstResponder])
        return YES;
    if ([self.txtPassword isFirstResponder])
        return YES;
    return NO;
}

- (void)cancelInputingText
{
    [self.txtEmail resignFirstResponder];
    [self.txtPassword resignFirstResponder];
}

@end
