//
//  SignUpView.m
//  FileThis
//
//  Created by Manh nguyen on 1/1/14.
//
//

#import "SignUpView.h"
#import "CommonLayout.h"
#import "Utils.h"
#import "FTSession.h"
#import "FTMobileAppDelegate.h"

#define MIN_PASSWORD_LENGTH 6
#define kTagAccountCreated  1

@implementation SignUpView

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
    
    self.imgLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FetchLogo_Text.png"]];
    [self.imgLogo setFrame:CGRectMake(60, 30, 250, 70)];
    [self addSubview:self.imgLogo];
    
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, [self.imgLogo bottom] + 40, self.frame.size.width, 30)];
    [self addSubview:self.titleView];
    self.lblTitle = [CommonLayout createLabel:CGRectMake(60, 0, 60, 30) fontSize:kFontSizeNormal isBold:YES textColor:kDarkGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_TRY_OUR", @"") superView:self.titleView];
    [self.lblTitle setWidth:60];
    [self.lblTitle setLeft:[self.lblTitle left] + 25];
    [self.lblTitle setTextAlignment:NSTextAlignmentLeft];
    
    self.lblForever = [CommonLayout createLabel:[self.lblTitle rectAtRight:2 width:85] fontSize:kFontSizeXNormal isBold:YES isItalic:YES textColor:kDarkGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_FREE", @"") superView:self.titleView];
    [self.lblForever setTextAlignment:NSTextAlignmentLeft];
    [self.lblForever setTextColor:kCabColorAll];
    
    self.lblVersion = [CommonLayout createLabel:[self.lblForever rectAtRight:2 width:80] fontSize:kFontSizeNormal isBold:YES textColor:kDarkGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_VERSION", @"") superView:self.titleView];
    [self.lblVersion setTextAlignment:NSTextAlignmentLeft];
    
    self.txtFirstName = [[BorderTextField alloc] initWithFrame:CGRectMake(30, [self.titleView bottom] + 10, self.frame.size.width - 60, 30)];
    [self.txtFirstName setPlaceholder:NSLocalizedString(@"ID_FIRST_NAME", @"")];
    [self.txtFirstName setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal]];
    [self.txtFirstName setBorderStyle:UITextBorderStyleNone];
    [self.txtFirstName setClearButtonMode:UITextFieldViewModeWhileEditing];
    self.txtFirstName.delegate = self;
    [self addSubview:self.txtFirstName];
    
    self.txtLastName = [[BorderTextField alloc] initWithFrame:[self.txtFirstName rectAtBottom:10 height:30]];
    [self.txtLastName setPlaceholder:NSLocalizedString(@"ID_LAST_NAME", @"")];
    [self.txtLastName setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal]];
    [self.txtLastName setBorderStyle:UITextBorderStyleNone];
    [self.txtLastName setClearButtonMode:UITextFieldViewModeWhileEditing];
    self.txtLastName.delegate = self;
    [self addSubview:self.txtLastName];
    
    self.txtEmail = [[BorderTextField alloc] initWithFrame:[self.txtLastName rectAtBottom:10 height:30]];
    [self.txtEmail setPlaceholder:NSLocalizedString(@"ID_EMAIL", @"")];
    [self.txtEmail setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal]];
    [self.txtEmail setBorderStyle:UITextBorderStyleNone];
    [self.txtEmail setClearButtonMode:UITextFieldViewModeWhileEditing];
    self.txtEmail.keyboardType = UIKeyboardTypeEmailAddress;
    self.txtEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.txtEmail.delegate = self;
    [self addSubview:self.txtEmail];
    
    self.txtPassword = [[BorderTextField alloc] initWithFrame:[self.txtEmail rectAtBottom:10 height:30]];
    [self.txtPassword setWidth:156];
    [self.txtPassword setPlaceholder:NSLocalizedString(@"ID_PASSWORD", @"")];
    [self.txtPassword setBorderStyle:UITextBorderStyleNone];
    [self.txtPassword setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal]];
    [self.txtPassword setClearButtonMode:UITextFieldViewModeWhileEditing];
    self.txtPassword.delegate = self;
    [self.txtPassword setSecureTextEntry:YES];
    [self addSubview:self.txtPassword];
    
    self.txtConfirmPassword = [[BorderTextField alloc] initWithFrame:[self.txtPassword rectAtRight:10 width:156]];
    [self.txtConfirmPassword setPlaceholder:NSLocalizedString(@"ID_VERIFY", @"")];
    [self.txtConfirmPassword setBorderStyle:UITextBorderStyleNone];
    [self.txtConfirmPassword setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal]];
    [self.txtConfirmPassword setClearButtonMode:UITextFieldViewModeWhileEditing];
    self.txtConfirmPassword.delegate = self;
    [self.txtConfirmPassword setSecureTextEntry:YES];
    [self.txtConfirmPassword setReturnKeyType:UIReturnKeyGo];
    [self addSubview:self.txtConfirmPassword];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake([self.txtPassword left], [self.txtPassword bottom], 125, 30)];
    [lbl setFont:[UIFont fontWithName:@"Merriweather-Italic" size:kFontSizeSmall] textColor:kDarkGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_AGREE_TERM_SERVICES1", @"") numberOfLines:0 textAlignment:NSTextAlignmentLeft];
    self.lblTerm1 = lbl;
    [self addSubview:lbl];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake([lbl right] + 3, [self.txtPassword bottom], 75, 30)];
    [lbl setFont:[UIFont fontWithName:@"Merriweather-Italic" size:kFontSizeSmall] textColor:kDarkGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_AGREE_TERM_SERVICES2", @"") numberOfLines:0 textAlignment:NSTextAlignmentLeft];
    self.lblTerm2 = lbl;
    [self addSubview:lbl];
    
    self.btnTermService = [CommonLayout createTextButton:CGRectMake([lbl right] + 3, [lbl top]+1, 150, 30) font:[UIFont fontWithName:@"Merriweather" size:kFontSizeSmall] text:NSLocalizedString(@"ID_TERM_SERVICE", @"") textColor:kCabColorAll touchTarget:self touchSelector:@selector(handleTermServiceButton:) superView:self];
    [self.btnTermService setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(self.txtPassword.center.x, [self.btnTermService bottom]- 10, 60, 30)];
    [lbl setFont:[UIFont fontWithName:@"Merriweather-Italic" size:kFontSizeSmall] textColor:kDarkGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_READ_OUR", @"") numberOfLines:0 textAlignment:NSTextAlignmentRight];
    self.lblReadOur = lbl;
    [self addSubview:lbl];
    
    self.btnPrivacy = [CommonLayout createTextButton:CGRectMake([lbl right] + 4, [lbl top] + 1, 150, 30) font:[UIFont fontWithName:@"Merriweather" size:kFontSizeSmall] text:NSLocalizedString(@"ID_PRIVACY", @"") textColor:kCabColorAll touchTarget:self touchSelector:@selector(handlePrivacyButton:) superView:self];
    [self.btnPrivacy setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    self.btnSignUp = [CommonLayout createTextButton:CGRectMake([self.txtPassword right] - 60, [self.btnPrivacy bottom], 120, 30) font:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal] text:NSLocalizedString(@"ID_SIGN_UP", @"") textColor:kWhiteColor touchTarget:self touchSelector:@selector(handleSignUpButton:) superView:self];
    [self.btnSignUp setBackgroundColor:kCabColorAll];
    
    self.btnBack = [CommonLayout createTextButton:CGRectMake([self.txtPassword left], self.frame.size.height - 35, 100, 30) font:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal] text:NSLocalizedString(@"ID_BACK", @"") textColor:kCabColorAll touchTarget:self touchSelector:@selector(handleBackButton:) superView:self];
    [self.btnBack setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    self.btnBackIcon = [CommonLayout createImageButton:CGRectMake(self.btnBack.frame.origin.x - 15, self.btnBack.frame.origin.y + 5, 11, 17) fontSize:kFontSizeNormal isBold:NO textColor:kCabColorAll backgroundImage:[UIImage imageNamed:@"arrow_prev_icon"] text:@"" touchTarget:self touchSelector:@selector(handleBackButton:) superView:self];
    
    self.btnLearnMore = [CommonLayout createTextButton:CGRectMake([self.btnBack right] + 10, self.frame.size.height - 35, self.frame.size.width - [self.btnBack right] - 10, 30) font:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal] text:NSLocalizedString(@"ID_LEARN_MORE", @"") textColor:kCabColorAll touchTarget:self touchSelector:@selector(handleLearnMoreButton:) superView:self];
    
    self.btnLearnMoreIcon = [CommonLayout createImageButton:CGRectMake(self.frame.size.width - 20, self.btnLearnMore.frame.origin.y + 5, 11, 17) fontSize:kFontSizeNormal isBold:NO textColor:kCabColorAll backgroundImage:[UIImage imageNamed:@"arrow_icon"] text:@"" touchTarget:self touchSelector:@selector(handleLearnMoreButton:) superView:self];
}

- (void)setupViewForIdiom:(UIUserInterfaceIdiom)aIdiom
{
    if (aIdiom == UIUserInterfaceIdiomPhone)
    {
        UIFont *font = [UIFont fontWithName:@"Merriweather-Italic" size:kFontSizeXSmall];
        self.lblTerm1.font = font;
        self.lblTerm2.font = font;
        self.btnTermService.titleLabel.font = font;
        
        self.btnBack.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
        [self.btnBack setWidth:60];
        
        [self.btnLearnMore setTitle:NSLocalizedString(@"ID_LEARN_MORE_COMPACT", @"") forState:UIControlStateNormal];
        self.btnLearnMore.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 4);
        [self.btnLearnMore setWidth:110];
        [self.btnLearnMore setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    }
}

#pragma mark - Private methods
- (void)makeEmpty {
    [self.txtFirstName setText:@""];
    [self.txtLastName setText:@""];
    [self.txtEmail setText:@""];
    [self.txtPassword setText:@""];
    [self.txtConfirmPassword setText:@""];
}

- (BOOL)validatePassword {
    NSString *password = [self.txtPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *passwordAgain = [self.txtConfirmPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([password length] < MIN_PASSWORD_LENGTH) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:[NSString stringWithFormat:NSLocalizedString(@"ID_PASSWORD_LENGTH", @""), MIN_PASSWORD_LENGTH] delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        return NO;
    } else if (![password isEqualToString:passwordAgain]) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:NSLocalizedString(@"ID_PASSWORD_NOT_MATCH", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        return NO;
    } else if ([password rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:[NSString stringWithFormat:NSLocalizedString(@"ID_PASSWORD_LENGTH", @""), MIN_PASSWORD_LENGTH] delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        return NO;
    } else if ([password rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location == NSNotFound) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:[NSString stringWithFormat:NSLocalizedString(@"ID_PASSWORD_LENGTH", @""), MIN_PASSWORD_LENGTH] delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        return NO;
    }
    
    return YES;
}

- (void)createUser:(NSString *)email
     withFirstName:(NSString *)firstname
      withLastName:(NSString *)lastname
      withPassword:(NSString *)password
 withPasswordAgain:(NSString *)passwordAgain {
    BOOL isFetch = YES;
    NSDictionary *params = @{@"first" : firstname,
                             @"last" : lastname,
                             @"email" : email,
                             @"type" : isFetch ? @"conn" : @"host",
                             @"password" : password,
                             @"create-password-repeat" : passwordAgain };
    //                             @"terms-of-service" :
    // TBD: what are "type" and "_" params? How to handle "terms-of-service"?
    // https://staging.filethis.com/ftapi/ftapi?jsonp=jQuery16204539361447095871_1353966856904&first=f&last=l&email=drewmwilson%40mailinator.com&password=brian6&create-password-repeat=brian6&terms-of-service=on&op=webnewaccount&type=conn&_=1353966940108
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView startLoadingInView:self.superview.superview message:NSLocalizedString(@"ID_CREATING_USER", @"")];
    });
    
    NSLog(@"Create user:%@, %@ %@", email, firstname, lastname);
    [[FTSession sharedSession] createUser:params onSuccess:^(id JSON) {
        if ([JSON[@"result"] isEqualToString:@"ERROR"]) {
            NSString *errorText = @"Cannot create account";
            id error = JSON[@"error"];
            if (error) {
                errorText = [@"Cannot create account." stringByAppendingFormat:@"\n%@",error[@"text"]];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:errorText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loadingView stopLoading];
            });
            
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView stopLoading];
        });
        
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_INFO", @"") tag:kTagAccountCreated content:NSLocalizedString(@"ID_ACCOUNT_CREATED", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"ID_OK", @"") otherButtonTitles:nil];
    } onFailure:^ {
        // Show alert fail
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView stopLoading];
        });
    }];
}

#pragma mark - Layout
- (void)layoutSubviews
{
    [self.loadingView setFrame:CGRectMake(0, 0, self.superview.superview.frame.size.width, self.superview.superview.frame.size.height)];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
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
    
    rect = self.titleView.frame;
    rect.origin.y = [self.imgLogo bottom] + 5;
    rect.origin.x = (self.frame.size.width - rect.size.width) / 2;
    self.titleView.frame = rect;
    
    int margin = 10;
    int width = self.frame.size.width - 2 * margin;
    self.txtFirstName.frame = CGRectMake(margin, [self.titleView bottom], width, 30);
    self.txtLastName.frame = [self.txtFirstName rectAtBottom:5 height:30];
    self.txtEmail.frame = [self.txtLastName rectAtBottom:5 height:30];
    self.txtPassword.frame = CGRectMake(margin, [self.txtEmail bottom] + 5, (width-5)/2, 30);
    self.txtConfirmPassword.frame = [self.txtPassword rectAtRight:5 width:(width-5)/2];

    rect = self.lblTerm1.frame;
    rect.origin.x = 4;
    rect.origin.y = [self.txtPassword bottom] + 2;
    rect.size.height = 20;
    rect.size.width = 115;
    self.lblTerm1.frame = rect;
    self.lblTerm2.frame = [self.lblTerm1 rectAtRight:0 width:70];
    self.btnTermService.frame = [self.lblTerm2 rectAtRight:0 width:120];
    
    margin = 5;
    rect = self.btnBack.frame;
    rect.origin.x = margin + 11;
    rect.origin.y = 324;
    self.btnBack.frame = rect;
    self.btnBackIcon.frame = CGRectMake(rect.origin.x - 11, rect.origin.y + 5, 11, 17);
    
    rect = self.btnLearnMore.frame;
    rect.origin.x = self.frame.size.width - rect.size.width - margin - 11;
    rect.origin.y = self.btnBack.frame.origin.y;
    self.btnLearnMore.frame = rect;
    rect = self.btnLearnMoreIcon.frame;
    rect.origin.x = self.frame.size.width - rect.size.width - margin;
    rect.origin.y = self.btnBackIcon.frame.origin.y;
    self.btnLearnMoreIcon.frame = rect;
    
    self.lblReadOur.frame = [self.lblTerm1 rectAtBottom:-2 height:20];
    self.btnPrivacy.frame = [self.lblReadOur rectAtRight:5 width:120];
    
    width = 215;
    self.btnSignUp.frame = CGRectMake((self.frame.size.width - width) / 2, 278, width, 30);
}

#pragma mark - Button events
- (void)handleTermServiceButton:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://filethis.com/terms-of-service/"]];
}

- (void)handlePrivacyButton:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://filethis.com/privacy-policy/"]];
}

- (void)handleLearnMoreButton:(id)sender {
    FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate goToCustomPagerViewController];
}

- (void)handleBackButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didBackButtonTouched:)]) {
        [self.delegate didBackButtonTouched:self];
    }
}

- (void)handleSignUpButton:(id)sender {
    [self.txtFirstName resignFirstResponder];
    [self.txtLastName resignFirstResponder];
    [self.txtEmail resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    [self.txtConfirmPassword resignFirstResponder];
    
    NSString *firstName = [self.txtFirstName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([firstName length] == 0) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:NSLocalizedString(@"ID_INVALID_FIRST_NAME", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        [self.txtFirstName becomeFirstResponder];
        return;
    }
    
    NSString *lastName = [self.txtLastName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([lastName length] == 0) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:NSLocalizedString(@"ID_INVALID_LAST_NAME", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        [self.txtLastName becomeFirstResponder];
        return;
    }
    
    NSString *email = [self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![Utils isValidEmail:email]) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:NSLocalizedString(@"ID_INVALID_EMAIL", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        [self.txtEmail becomeFirstResponder];
        return;
    }
    
    if ([self validatePassword]) {
        NSString *password = [self.txtPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *confirmPassword = [self.txtConfirmPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self createUser:email
           withFirstName:firstName
            withLastName:lastName
            withPassword:password
       withPasswordAgain:confirmPassword];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.txtFirstName) {
        [self.txtLastName becomeFirstResponder];
    } else if(textField == self.txtLastName) {
        [self.txtEmail becomeFirstResponder];
    } else if(textField == self.txtEmail) {
        [self.txtPassword becomeFirstResponder];
    } else if (textField == self.txtPassword) {
        [self.txtConfirmPassword becomeFirstResponder];
    } else if (textField == self.txtConfirmPassword) {
        [self handleSignUpButton:self.btnSignUp];
    }
    
    return YES;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kTagAccountCreated) {
        NSString *email = [self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *password = [self.txtPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([self.delegate respondsToSelector:@selector(didAccountCreated:password:)]) {
            [self.delegate didAccountCreated:email password:password];
        }
        
        [self makeEmpty];
    }
}

#pragma mark - Public methods
- (BOOL)isInputingText
{
    if ([self.txtFirstName isFirstResponder])
        return YES;
    if ([self.txtLastName isFirstResponder])
        return YES;
    if ([self.txtEmail isFirstResponder])
        return YES;
    if ([self.txtPassword isFirstResponder])
        return YES;
    if ([self.txtConfirmPassword isFirstResponder])
        return YES;
    return NO;
}

- (void)cancelInputingText
{
    [self.txtFirstName resignFirstResponder];
    [self.txtLastName resignFirstResponder];
    [self.txtEmail resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    [self.txtConfirmPassword resignFirstResponder];
}

@end
